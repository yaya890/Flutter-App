from flask import Flask, jsonify, request, url_for, send_file
from flask_mysqldb import MySQL
from flask_cors import CORS
import os
import logging
from werkzeug.utils import secure_filename
import resume_sorter
import openai
import json
import requests
from sentence_transformers import SentenceTransformer, util
from concurrent.futures import ThreadPoolExecutor
import tempfile

import pdfplumber
from flask import jsonify

import tempfile
import pytesseract
from pdf2image import convert_from_path

import torch
import pdfplumber
import re
from transformers import DistilBertTokenizer, DistilBertModel
from sklearn.metrics.pairwise import cosine_similarity
\

# Load the S-BERT model (e.g., 'all-MiniLM-L6-v2' is lightweight and efficient)
sbert_model = SentenceTransformer('paraphrase-MiniLM-L6-v2')

# Initialize Flask app
app = Flask(__name__)

logging.basicConfig(level=logging.INFO)

# Enable CORS for all routes (adjust origins if needed)
CORS(app, resources={r"/*": {"origins": "*"}})

# Configure MySQL connection
app.config['MYSQL_HOST'] = 'localhost'  # Your database host
app.config['MYSQL_USER'] = 'root'  # Your MySQL username
app.config['MYSQL_PASSWORD'] = 'yara'  # Your MySQL password
app.config['MYSQL_DB'] = 'ElpisHR'  # Your database name

# Configure file upload folder
UPLOAD_FOLDER = 'uploads'
BASE_URL = "http://127.0.0.1:39542/" 
os.makedirs(UPLOAD_FOLDER, exist_ok=True)
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER

mysql = MySQL(app)

# Configure logging
logging.basicConfig(level=logging.DEBUG)


@app.route('/', methods=['GET'])
def home():
    return "Hello, Flask is working!"


# /add_job Endpoint
@app.route('/add_job', methods=['POST'])
def add_job():
    data = request.json
    title = data.get('title')
    department = data.get('department')
    description = data.get('description')
    requirements = data.get('requirements')
    job_questions = data.get('jobQuestions', "")  # Default to empty string if not provided

    # Validate required fields
    if not all([title, department, description, requirements]):
        logging.error("Missing required fields in the request.")
        return jsonify({"error": "Missing required fields"}), 400

    try:
        cursor = mysql.connection.cursor()
        cursor.execute("""
            INSERT INTO Job (title, department, description, requirements, jobQuestions, status)
            VALUES (%s, %s, %s, %s, %s, %s)
        """, (title, department, description, requirements, job_questions, "open"))
        mysql.connection.commit()
        cursor.close()
        logging.info(f"Job added successfully: {title}")
        return jsonify({"message": "Job added successfully"}), 201
    except Exception as e:
        logging.error(f"Error adding job: {str(e)}")
        return jsonify({"error": str(e)}), 500


# /get_open_jobs Endpoint
@app.route('/get_open_jobs', methods=['GET'])
def get_open_jobs():
    try:
        cursor = mysql.connection.cursor()
        cursor.execute("""
            SELECT jobID, title, description FROM Job WHERE status = 'open'
        """)
        jobs = cursor.fetchall()
        cursor.close()

        # Convert results to a list of dictionaries
        result = [{"jobID": job[0], "title": job[1], "description": job[2]} for job in jobs]
        logging.info("Open jobs retrieved successfully.")
        return jsonify(result), 200
    except Exception as e:
        logging.error(f"Error retrieving open jobs: {str(e)}")
        return jsonify({"error": str(e)}), 500


# /get_job_details/<int:job_id> Endpoint
@app.route('/get_job_details/<int:job_id>', methods=['GET'])
def get_job_details(job_id):
    try:
        cursor = mysql.connection.cursor()
        cursor.execute("""
            SELECT title, department, description, requirements 
            FROM Job WHERE jobID = %s
        """, (job_id,))
        job = cursor.fetchone()
        cursor.close()

        if job:
            result = {
                "title": job[0],
                "department": job[1],
                "description": job[2],
                "requirements": job[3]
            }
            logging.info(f"Job details retrieved successfully for jobID: {job_id}")
            return jsonify(result), 200
        else:
            logging.warning(f"No job found with jobID: {job_id}")
            return jsonify({"error": "Job not found"}), 404
    except Exception as e:
        logging.error(f"Error retrieving job details: {str(e)}")
        return jsonify({"error": str(e)}), 500


# /upload_cv Endpoint
@app.route('/upload_cv', methods=['POST'])
def upload_cv():
    if 'file' not in request.files and not request.data:
        logging.error("No file part or data in the request.")
        return jsonify({"error": "No file part or data in the request"}), 400

    try:
        if 'file' in request.files:
            # For native file uploads (e.g., from mobile apps)
            file = request.files['file']
            if file.filename == '':
                logging.error("No selected file.")
                return jsonify({"error": "No selected file"}), 400

            if not file.filename.endswith('.pdf'):
                logging.error("Invalid file type. Only PDFs are allowed.")
                return jsonify({"error": "Invalid file type. Only PDFs are allowed."}), 400

            # Save file
            filename = secure_filename(file.filename)
            filepath = os.path.join(app.config['UPLOAD_FOLDER'], filename)
            file.save(filepath)
        else:
            # For web-based file uploads (e.g., Flutter web)
            filename = secure_filename(request.headers.get('Filename', 'uploaded_file.pdf'))
            if not filename.endswith('.pdf'):
                logging.error("Invalid file type. Only PDFs are allowed.")
                return jsonify({"error": "Invalid file type. Only PDFs are allowed."}), 400

            filepath = os.path.join(app.config['UPLOAD_FOLDER'], filename)
            with open(filepath, 'wb') as f:
                f.write(request.data)

        logging.info(f"CV uploaded successfully: {filename}")
        return jsonify({"file_path": filepath, "message": "CV uploaded successfully"}), 201

    except Exception as e:
        logging.error(f"Error uploading CV: {str(e)}")
        return jsonify({"error": str(e)}), 500


# /save_application Endpoint
@app.route('/save_application', methods=['POST'])
def save_application():
    data = request.json
    job_id = data.get('jobID')
    cv_file_path = data.get('filePath')
    candidate_id = 1  # Set CandidateID to 1

    # Validate required fields
    if not all([job_id, cv_file_path]):
        logging.error("Missing required fields in the request.")
        return jsonify({"error": "Missing required fields"}), 400

    try:
        cursor = mysql.connection.cursor()
        cursor.execute("""
            INSERT INTO JobApplication (candidateID, jobID, cvPath)
            VALUES (%s, %s, %s)
        """, (candidate_id, job_id, cv_file_path))
        mysql.connection.commit()
        cursor.close()

        logging.info(f"Application sent successfully for CandidateID: {candidate_id}, jobID: {job_id}")
        return jsonify({"message": "Application saved successfully"}), 201
    except Exception as e:
        logging.error(f"Error application not sent: {str(e)}")
        return jsonify({"error": str(e)}), 500



#display job posts
@app.route('/get_jobs', methods=['GET'])
def get_jobs():
    try:
        cursor = mysql.connection.cursor()
        cursor.execute("""
            SELECT j.jobID, j.title, j.description, j.status
            FROM Job j
            ORDER BY j.jobID DESC
        """)
        jobs = cursor.fetchall()
        cursor.close()

        # Convert results to a list of dictionaries
        result = [{"jobID": job[0], "title": job[1], "description": job[2], "status": job[3]} for job in jobs]

        return jsonify(result), 200
    except Exception as e:
        logging.error(f"Error retrieving jobs: {str(e)}")
        return jsonify({"error": str(e)}), 500



# Get Applications Endpoint
@app.route('/get_application/<int:jobID>', methods=['GET'])
def get_application(jobID):
    try:
        cursor = mysql.connection.cursor()
        query = """
            SELECT 
                ja.applicationID,
                ja.cvPath, 
                u.name
            FROM 
                jobapplication ja
            JOIN 
                candidate c ON ja.candidateID = c.candidateID
            JOIN 
                user u ON c.userID = u.userID
            WHERE 
                ja.jobID = %s
        """
        cursor.execute(query, (jobID,))
        applications = cursor.fetchall()
        cursor.close()

        if not applications:
            logging.warning(f"No applications found for JobID: {jobID}")
            return jsonify({"message": "No applications found", "data": []}), 200

        # Build result list
        result = []
        for app in applications:
            cleaned_path = os.path.basename(app[1]).replace("\\", "/")
            result.append({
                "applicationID": app[0],
                "cvPath": f"{BASE_URL}{UPLOAD_FOLDER}/{cleaned_path}",
                "name": app[2]
            })

        logging.info(f"Applications retrieved successfully for JobID: {jobID}")
        return jsonify({"message": "Applications retrieved successfully", "data": result}), 200

    except Exception as e:
        logging.error(f"Error retrieving applications for JobID {jobID}: {str(e)}")
        return jsonify({"message": "Error retrieving applications", "error": str(e)}), 500


# File Download Route
@app.route('/uploads/<path:filename>', methods=['GET'])
def download_file(filename):
    try:
        # Ensure the full file path is correct
        file_path = os.path.join(UPLOAD_FOLDER, filename)
        if os.path.exists(file_path):
            logging.info(f"Serving file: {file_path}")
            return send_file(file_path)
        else:
            logging.warning(f"File not found: {file_path}")
            return jsonify({"error": "File not found"}), 404
    except Exception as e:
        logging.error(f"Error serving file {filename}: {str(e)}")
        return jsonify({"error": str(e)}), 500
        








def extract_resume_text(file_path):
    """
    Extract text from a PDF file using pdfplumber with OCR fallback.
    """
    try:
        with pdfplumber.open(file_path) as pdf:
            text = ''.join([page.extract_text() for page in pdf.pages if page.extract_text()])
        if text.strip():
            return text.strip()
        else:
            logging.warning(f"pdfplumber failed to extract text for {file_path}. Using OCR as fallback.")
    except Exception as e:
        logging.warning(f"pdfplumber error for {file_path}: {e}. Using OCR as fallback.")

    # OCR fallback
    try:
        images = convert_from_path(file_path)
        text = ' '.join(pytesseract.image_to_string(image) for image in images)
        return text.strip()
    except Exception as e:
        logging.error(f"OCR failed for {file_path}: {e}")
        return ""

def sbert_sort_resumes(job_description, resumes, default_score=0.0, batch_size=16):
    """
    Use Sentence-BERT to rank resumes based on a job description.
    """
    try:
        job_embedding = sbert_model.encode(job_description, convert_to_tensor=True)
        resume_embeddings = []

        for i in range(0, len(resumes), batch_size):
            batch = resumes[i:i + batch_size]
            batch_embeddings = sbert_model.encode(batch, convert_to_tensor=True)
            resume_embeddings.append(batch_embeddings)

        resume_embeddings = torch.cat(resume_embeddings)
        similarities = util.pytorch_cos_sim(job_embedding, resume_embeddings)

        results = [
            {"resume": resumes[i], "score": float(similarities[0][i]) if resumes[i].strip() else default_score}
            for i in range(len(resumes))
        ]

        sorted_results = sorted(results, key=lambda x: x['score'], reverse=True)
        return sorted_results

    except Exception as e:
        logging.error(f"Error using Sentence-BERT: {e}")
        return []

def cache_scores(jobID, scores):
    """
    Save the scores for applications of a job in the cache.
    """
    try:
        cursor = mysql.connection.cursor()
        for score in scores:
            cursor.execute(
                """
                INSERT INTO CachedScores (jobID, applicationID, score)
                VALUES (%s, %s, %s)
                ON DUPLICATE KEY UPDATE score = VALUES(score)
                """,
                (jobID, score['applicationID'], score['score'])
            )
        mysql.connection.commit()
        cursor.close()
        logging.info(f"Scores cached for jobID {jobID}.")
    except Exception as e:
        logging.error(f"Error caching scores for jobID {jobID}: {e}")

def get_cached_scores(jobID):
    """
    Retrieve cached scores for a job.
    """
    try:
        cursor = mysql.connection.cursor()
        cursor.execute("SELECT applicationID, score FROM CachedScores WHERE jobID = %s", (jobID,))
        cached_scores = cursor.fetchall()
        cursor.close()
        logging.info(f"Retrieved cached scores for jobID {jobID}.")
        return {row[0]: row[1] for row in cached_scores}
    except Exception as e:
        logging.error(f"Error retrieving cached scores for jobID {jobID}: {e}")
        return {}

@app.route('/sort_applications/<int:jobID>', methods=['POST', 'GET'])
def sort_applications_sbert(jobID):
    try:
        logging.info(f"Received request to sort applications for jobID: {jobID}")
        cursor = mysql.connection.cursor()

        # Fetch job requirements
        cursor.execute("SELECT requiredSkills, experienceYears, education FROM Job WHERE jobID = %s", (jobID,))
        job = cursor.fetchone()

        if not job:
            logging.error("No job found with the given jobID.")
            return jsonify({"error": "Job not found"}), 404

        job_description = f"""
        Required Skills: {job[0] if job[0] else "None"}.
        Experience Years: {job[1] if job[1] else "None"}.
        Education: {job[2] if job[2] else "None"}.
        """

        # Fetch applications for the job
        cursor.execute("""
            SELECT ja.applicationID, ja.cvPath, u.name
            FROM jobapplication ja
            JOIN candidate c ON ja.candidateID = c.candidateID
            JOIN user u ON c.userID = u.userID
            WHERE ja.jobID = %s
        """, (jobID,))
        applications = cursor.fetchall()
        cursor.close()

        if not applications:
            logging.warning("No applications found for the given jobID.")
            return jsonify({"message": "No applications found", "data": []}), 200

        # Check for cached scores
        cached_scores = get_cached_scores(jobID)
        if len(cached_scores) == len(applications):
            logging.info(f"Using cached scores for jobID {jobID}.")
            cleaned_path = os.path.basename(app[1]).replace("\\", "/")  # Clean the path
            file_url = f"{BASE_URL}{UPLOAD_FOLDER}/{cleaned_path}"  # Construct the URL
            response = [
                {
                    "applicationID": app[0],
                    "name": app[2],
                    "cvPath": file_url,
                    "score": cached_scores[app[0]]
                }
                for app in applications
            ]
            return jsonify({"sorted_applications": sorted(response, key=lambda x: x['score'], reverse=True)}), 200


        # Process resumes in parallel
        resumes = []
        cleaned_path = os.path.basename(app[1]).replace("\\", "/")  # Clean the path
        file_url = f"{BASE_URL}{UPLOAD_FOLDER}/{cleaned_path}"  # Construct the URL
        application_data = [
            {"applicationID": app[0], "name": app[2], "cvPath": file_url}
            for app in applications
        ]

        def process_resume(file_url):
            try:
                response = requests.get(file_url)
                response.raise_for_status()
                with tempfile.NamedTemporaryFile(delete=False, suffix=".pdf") as temp_file:
                    temp_filename = temp_file.name
                    temp_file.write(response.content)
                text = extract_resume_text(temp_filename)
                os.remove(temp_filename)
                return text if text else "EMPTY_RESUME"
            except Exception as e:
                logging.error(f"Error processing file {file_url}: {e}")
                return "EMPTY_RESUME"

        with ThreadPoolExecutor() as executor:
            resume_texts = list(executor.map(lambda app: process_resume(app["cvPath"]), application_data))

        if not resume_texts:
            logging.error("No resumes could be read. Check the file paths or formats.")
            return jsonify({"error": "No resumes could be read."}), 400

        # Use Sentence-BERT to sort resumes
        logging.info("Sending resumes to S-BERT for sorting...")
        sorted_resumes = sbert_sort_resumes(job_description, resume_texts, default_score=0.0)

        if not sorted_resumes:
            logging.error("S-BERT returned no results. Check the job description or resumes.")
            return jsonify({"error": "S-BERT returned no results."}), 500

        # Combine sorted resumes with application data and cache scores
        response = [
            {
                "applicationID": application_data[i]["applicationID"],
                "name": application_data[i]["name"],
                "cvPath": application_data[i]["cvPath"],
                "score": sorted_resumes[i]["score"]
            }
            for i in range(len(application_data))
        ]
        cache_scores(jobID, response)

        logging.info("Successfully sorted applications.")
        return jsonify({"sorted_applications": sorted(response, key=lambda x: x['score'], reverse=True)}), 200

    except Exception as e:
        logging.error(f"Error sorting applications for jobID {jobID}: {e}")
        return jsonify({"error": str(e)}), 500





if __name__ == '__main__':
    # Enable Flask development server
    app.run(debug=True, host="0.0.0.0", port=39542)