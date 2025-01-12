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
import re

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


#open ai key
openai.api_key = "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"


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


# get jobs invitations 
@app.route('/get_invitations', methods=['GET'])
def get_invitations():
    candidate_id = request.args.get('candidateID')  # Retrieve candidateID from query parameters
    if not candidate_id:
        logging.error("Missing candidateID in request.")
        return jsonify({"error": "candidateID is required"}), 400

    try:
        # Fetch job applications for the candidate where invitationID is not null
        cursor = mysql.connection.cursor()
        cursor.execute("""
            SELECT ja.invitationID, ja.jobID
            FROM jobapplication ja
            WHERE ja.candidateID = %s AND ja.invitationID IS NOT NULL
        """, (candidate_id,))
        applications = cursor.fetchall()

        if not applications:
            logging.info(f"No invitations found for candidateID: {candidate_id}")
            return jsonify({"invitations": []}), 200  # Return empty list if no invitations are found

        invitations = []
        for invitation_id, job_id in applications:
            # Fetch interview invitation details
            cursor.execute("""
                SELECT start, end, comment, invitationID
                FROM interview_invitation
                WHERE invitationID = %s
            """, (invitation_id,))
            invitation_details = cursor.fetchone()

            if not invitation_details:
                continue

            # Fetch the job title
            cursor.execute("""
                SELECT title
                FROM job
                WHERE jobID = %s
            """, (job_id,))
            job_title = cursor.fetchone()

            if not job_title:
                continue

            # Append invitation details to the result list
            invitations.append({
                "title": job_title[0],
                "start": invitation_details[0],
                "end": invitation_details[1],
                "comment": invitation_details[2],
                "invitationID": invitation_details[3],

            })

        cursor.close()
        logging.info(f"Invitations retrieved successfully for candidateID: {candidate_id}")
        return jsonify({"invitations": invitations}), 200

    except Exception as e:
        logging.error(f"Error fetching invitations for candidateID {candidate_id}: {str(e)}")
        return jsonify({"error": str(e)}), 500










# Example jobQuestions string stored in one line
job_questions_raw = "1. What is your strength? 2. Describe your experience with project management. 3. How do you handle deadlines?"

# Extract questions using regex for numbers followed by a period and a space
job_questions_list = re.split(r'\d+\.\s', job_questions_raw)

# Remove any empty strings and strip extra whitespace
job_questions_list = [q.strip() for q in job_questions_list if q.strip()]

# Example output:
# ['What is your strength?', 'Describe your experience with project management.', 'How do you handle deadlines?']



# chatbot
@app.route('/start_interview', methods=['POST'])
def start_interview():
    try:
        # Parse incoming data
        data = request.json
        invitation_id = data.get('invitationID')

        if not invitation_id:
            return jsonify({"error": "invitationID is required"}), 400

        # Step 1: Get jobID from interview_invitation
        cursor = mysql.connection.cursor()
        cursor.execute("""
            SELECT jobID FROM interview_invitation WHERE invitationID = %s
        """, (invitation_id,))
        job_id_result = cursor.fetchone()

        if not job_id_result:
            return jsonify({"error": "No job found for the provided invitationID"}), 404

        job_id = job_id_result[0]

        # Step 2: Get job details from the job table
        cursor.execute("""
            SELECT title, department, description, jobQuestions, requiredSkills, experienceYears, education 
            FROM job WHERE jobID = %s
        """, (job_id,))
        job_data = cursor.fetchone()
        cursor.close()

        if not job_data:
            return jsonify({"error": "No job details found for the provided jobID"}), 404

        # Extract job details
        title, department, description, job_questions_raw, required_skills, experience_years, education = job_data

        # Step 3: Process job questions stored in one line
        import re
        job_questions_list = re.split(r'\d+\.\s', job_questions_raw)
        job_questions_list = [q.strip() for q in job_questions_list if q.strip()]  # Clean and filter

        # Step 4: Prepare AI conversation flow
        job_details = {
            "title": title,
            "department": department,
            "description": description,
            "requiredSkills": required_skills,
            "experienceYears": experience_years,
            "education": education,
        }

        initial_prompt = f"""
        You are an AI interviewer for the job:
        Title: {title}
        Department: {department}
        Description: {description}
        Required Skills: {required_skills}
        Experience Years: {experience_years}
        Education: {education}

        Start by greeting the candidate and proceed with these questions:
        {', '.join(job_questions_list)}
        Conclude by thanking the candidate.
        """

        # Generate the initial response from the bot
        response = openai.ChatCompletion.create(
            model="gpt-3.5-turbo",
            messages=[{"role": "system", "content": initial_prompt}],
            max_tokens=500,
            temperature=0.7,
        )
        bot_message = response['choices'][0]['message']['content']

        return jsonify({
            "message": "Interview started successfully.",
            "bot_message": bot_message,
            "job_details": job_details,  # Pass job details for evaluation later
            "job_questions": job_questions_list
        }), 200

    except Exception as e:
        logging.error(f"Error in /start_interview: {str(e)}")
        return jsonify({"error": str(e)}), 500





@app.route('/send_message', methods=['POST'])
def send_message():
    try:
        # Parse incoming data
        data = request.json
        user_message = data.get('message')
        chat_history = data.get('chat_history')  # Full conversation context
        invitation_id = data.get('invitationID')
        job_details = data.get('jobDetails')  # Include job details for evaluation

        if not user_message or not chat_history or not invitation_id or not job_details:
            return jsonify({"error": "message, chat_history, invitationID, and jobDetails are required"}), 400

        # Add the user's message to the chat history
        messages = [{"role": "system", "content": "You are an AI interviewer."}] + chat_history
        messages.append({"role": "user", "content": user_message})

        # Step 1: Get the bot's response
        response = openai.ChatCompletion.create(
            model="gpt-3.5-turbo",
            messages=messages,
            max_tokens=500,
            temperature=0.7,
        )
        bot_message = response['choices'][0]['message']['content']

        # Step 2: Detect if the conversation is ending
        is_chat_ending = "Thank you for your time" in bot_message or "interview is complete" in bot_message

        if is_chat_ending:
            # Step 3: Generate the summary
            summary_prompt = f"""
            Based on the following interview for the job:
            {job_details}

            The conversation is as follows:
            {json.dumps(chat_history, indent=2)}

            Evaluate the candidate's responses considering:
            - Relevance to the job requirements and skills.
            - Strengths and weaknesses in their responses.
            - Performance metrics like response timing and conciseness.
            - Provide a summary and a rating out of 10.
            """
            summary_response = openai.ChatCompletion.create(
                model="gpt-3.5-turbo",
                messages=[
                    {"role": "system", "content": "You are an AI summarizer."},
                    {"role": "user", "content": summary_prompt}
                ],
                max_tokens=300,
                temperature=0.7,
            )
            summary_text = summary_response['choices'][0]['message']['content']

            # Extract rating from the summary
            import re
            rating_match = re.search(r'(\d+)/10', summary_text)
            rating = rating_match.group(1) if rating_match else "N/A"

            # Step 4: Store the summary and rating in the database
            cursor = mysql.connection.cursor()
            cursor.execute("""
                INSERT INTO chatbot (invitationID, interviewSummary, rating)
                VALUES (%s, %s, %s)
            """, (invitation_id, summary_text, rating))
            mysql.connection.commit()
            cursor.close()

            # Return the final bot message with no additional UI action required
            return jsonify({"bot_message": bot_message, "is_chat_ending": True}), 200

        # Return the bot's response if the conversation is ongoing
        return jsonify({"bot_message": bot_message, "is_chat_ending": False}), 200

    except Exception as e:
        logging.error(f"Error in /send_message: {str(e)}")
        return jsonify({"error": str(e)}), 500




if __name__ == '__main__':
    # Enable Flask development server
    app.run(debug=True, host="0.0.0.0", port=39542)


