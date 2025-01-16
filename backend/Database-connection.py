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

        Start the interview in a conversational manner:
        1. Greet the candidate warmly and wait for their response.
        2. Briefly explain the job role to the candidate.
        3. Start asking the job questions one by one from the provided list.
        4. Engage dynamically with their responses and make follow-up comments or questions relevant to the job role.
        5. Conclude by thanking the candidate.
        """

        # Generate the initial greeting message from the bot
        response = openai.ChatCompletion.create(
            model="gpt-3.5-turbo",
            messages=[
                {"role": "system", "content": initial_prompt},
                {"role": "user", "content": "Start the interview by greeting the candidate."},
            ],
            max_tokens=200,
            temperature=0.7,
        )
        bot_message = response['choices'][0]['message']['content']

        return jsonify({
            "message": "Interview started successfully.",
            "bot_message": bot_message,
            "job_details": job_details,  # Pass job details for dynamic evaluation in send_message
            "job_questions": job_questions_list,  # Pass the list of questions
            "currentQuestionIndex": 0  # Start from the first question
        }), 200

    except Exception as e:
        logging.error(f"Error in /start_interview: {str(e)}")
        return jsonify({"error": str(e)}), 500


# Endpoint: Send Message
@app.route('/send_message', methods=['POST'])
def send_message():
    try:
        # Parse incoming data
        data = request.json
        user_message = data.get('message')
        chat_history = data.get('chat_history', [])
        job_details = data.get('jobDetails')
        current_question_index = data.get('currentQuestionIndex')
        job_questions = data.get('jobQuestions')
        invitation_id = data.get('invitationID')  # Add interview ID for identifying interviews

        # Validate required fields
        if not user_message:
            return jsonify({"error": "Missing field: 'message'"}), 400
        if not job_details:
            return jsonify({"error": "Missing field: 'jobDetails'"}), 400
        if current_question_index is None:
            return jsonify({"error": "Missing field: 'currentQuestionIndex'"}), 400
        if not job_questions:
            return jsonify({"error": "Missing field: 'jobQuestions'"}), 400

        # Add user's message to chat history
        chat_history.append({"role": "user", "content": user_message})

        # Determine the flow
        is_chat_ending = False
        ask_for_questions = False
        bot_message = ""

        if current_question_index < len(job_questions):
            # If there are more questions, proceed to the next question
            next_question = job_questions[current_question_index]
            current_question_index += 1
            bot_message = f"Thank you for sharing! Here's the next question: {next_question}"
        elif current_question_index == len(job_questions):
            # If all questions are done, ask if the candidate has questions
            ask_for_questions = True
            bot_message = "Thank you for answering all our questions. Do you have any questions you'd like to ask about the role, our team, or the company?"
            current_question_index += 1
        elif ask_for_questions and user_message.lower() in ["yes", "yeah", "yup", "sure"]:
            # Candidate wants to ask a question
            bot_message = "Great! Please go ahead and ask your question."
        elif ask_for_questions and user_message.lower() not in ["yes", "yeah", "yup", "sure", "no", "nah"]:
            # Respond to candidate's question
            follow_up_prompt = f"""
            You are an AI interviewer. The candidate asked:
            "{user_message}"

            Please provide a clear, professional, and relevant answer to their question based on the following job details:
            {json.dumps(job_details, indent=2)}.

            After providing your response, ask if they have more questions.
            """
            response_to_question = openai.ChatCompletion.create(
                model="gpt-3.5-turbo",
                messages=[
                    {"role": "system", "content": "You are an AI interviewer."},
                    {"role": "user", "content": follow_up_prompt},
                ],
                max_tokens=300,
                temperature=0.7,
            )
            response_to_question_message = response_to_question['choices'][0]['message']['content']
            bot_message = f"{response_to_question_message}\n\nDo you have any other questions I can assist you with?"
        elif "no" in user_message.lower():
            # Candidate says they have no more questions
            bot_message = "Thank you for your time and for participating in this interview! We appreciate your responses and interest in the role. Have a great day!"
            is_chat_ending = True

        # Add bot's message to chat history
        chat_history.append({"role": "assistant", "content": bot_message})

        # If chat is ending, generate the summary
        if is_chat_ending:
            summary_prompt = f"""
            Based on the following conversation history, generate a detailed interview summary:

            Chat History:
            {json.dumps(chat_history, indent=2)}

            Job Details:
            {json.dumps(job_details, indent=2)}

            Include:
            - How the interview went.
            - How the candidate performed based on their answers.
            - Whether they are a good match for the job requirements.
            - A score out of 10 on how well they match the job based on this interview.
            """
            summary_response = openai.ChatCompletion.create(
                model="gpt-3.5-turbo",
                messages=[
                    {"role": "system", "content": "You are an AI interviewer."},
                    {"role": "user", "content": summary_prompt},
                ],
                max_tokens=500,
                temperature=0.7,
            )
            summary = summary_response['choices'][0]['message']['content']

            # Save the summary in the database
            try:
                
                cursor = mysql.connection.cursor()
                cursor.execute(
                   """
                   INSERT INTO chatbot (summary, invitationID)
                   VALUES (%s, %s)
                   """,
                   (summary, invitation_id),
                )
                conn.commit()
                conn.close()
            except Exception as db_error:
                logging.error(f"Database error: {str(db_error)}")

        return jsonify({
            "bot_message": bot_message,
            "currentQuestionIndex": current_question_index,
            "chat_history": chat_history,
            "is_chat_ending": is_chat_ending
        }), 200

    except Exception as e:
        logging.error(f"Error in /send_message: {str(e)}")
        return jsonify({"error": str(e)}), 500






# HR invitations 
@app.route('/interview_invitations', methods=['GET'])
def get_interview_invitations():
    try:
        # Connect to the database
        cursor = mysql.connection.cursor()

        # Query to retrieve interview invitations with job titles and jobID
        cursor.execute("""
            SELECT 
                i.start AS start, 
                i.end AS end, 
                i.comment AS comment, 
                j.title AS title,
                i.jobID AS jobID
            FROM 
                interview_invitation i
            JOIN 
                job j ON i.jobID = j.jobID
        """)

        # Fetch all results
        results = cursor.fetchall()
        cursor.close()

        # Format the results into JSON
        invitations = [
            {
                "start": str(row[0]),
                "end": str(row[1]),
                "comment": row[2],
                "title": row[3],
                "jobID": row[4]  # Include jobID in the response
            }
            for row in results
        ]

        logging.info("Interview invitations retrieved successfully.")
        return jsonify(invitations), 200
    except Exception as e:
        logging.error(f"Error retrieving interview invitations: {str(e)}")
        return jsonify({"error": str(e)}), 500




### Endpoint 1: Fetch Jobs
@app.route('/get_all_jobs', methods=['GET'])
def get_all_jobs():
    try:
        cursor = mysql.connection.cursor()
        query = "SELECT jobID, title FROM job"
        cursor.execute(query)
        jobs = cursor.fetchall()
        cursor.close()

        # Format response as a list of dictionaries
        job_list = [{"jobID": job[0], "title": job[1]} for job in jobs]

        return jsonify(job_list), 200
    except Exception as e:
        logging.error(f"Error fetching jobs: {str(e)}")
        return jsonify({"error": str(e)}), 500



### Endpoint 2: Add New Invitation
@app.route('/add_invitation', methods=['POST'])
def add_invitation():
    try:
        # Parse JSON request data
        data = request.json
        job_id = data.get('jobID')
        start = data.get('start')
        end = data.get('end')
        comment = data.get('comment')

        # Validate required fields
        if not all([job_id, start, end, comment]):
            return jsonify({"error": "Missing required fields"}), 400

        # Insert data into the interview_invitation table
        cursor = mysql.connection.cursor()
        query = """
            INSERT INTO interview_invitation (jobID, start, end, comment)
            VALUES (%s, %s, %s, %s)
        """
        cursor.execute(query, (job_id, start, end, comment))
        mysql.connection.commit()
        cursor.close()

        logging.info(f"New invitation added: jobID={job_id}, start={start}, end={end}")
        return jsonify({"message": "Invitation added successfully"}), 201
    except Exception as e:
        logging.error(f"Error adding invitation: {str(e)}")
        return jsonify({"error": str(e)}), 500




# get top candidates 
# Get top candidates
@app.route('/get_top_candidates', methods=['GET'])
def get_top_candidates():
    try:
        # Get jobID from query parameters
        job_id = request.args.get('jobID')
        if not job_id:
            return jsonify({"error": "jobID is required"}), 400

        # Connect to the database
        cursor = mysql.connection.cursor()

        # Query to retrieve candidates and their scores
        cursor.execute("""
            SELECT 
                ja.candidateID, 
                ja.last_ranking, 
                ja.last_score
            FROM 
                jobapplication ja
            WHERE 
                ja.jobID = %s
        """, (job_id,))
        job_applications = cursor.fetchall()

        if not job_applications:
            return jsonify({"message": "No candidates found for the given jobID"}), 404

        # Build a list of candidate details
        candidates = []
        for candidate_id, last_ranking, last_score in job_applications:
            # Get the userID of the candidate
            cursor.execute("""
                SELECT userID 
                FROM candidate 
                WHERE candidateID = %s
            """, (candidate_id,))
            user = cursor.fetchone()

            if not user:
                continue

            user_id = user[0]

            # Get the name of the user
            cursor.execute("""
                SELECT name 
                FROM user 
                WHERE userID = %s
            """, (user_id,))
            user_name = cursor.fetchone()

            if not user_name:
                continue

            candidates.append({
                "candidateID": candidate_id,  # Include candidateID
                "name": user_name[0],
                "last_ranking": last_ranking,
                "last_score": last_score
            })

        cursor.close()

        # Sort candidates by last_score (descending) and last_ranking (ascending)
        sorted_candidates = sorted(
            candidates,
            key=lambda x: (x["last_ranking"], -x["last_score"])
        )

        # Add the jobID at the end of the list
        sorted_candidates.append({"jobID": job_id})

        logging.info(f"Top candidates retrieved successfully for jobID: {job_id}")
        return jsonify(sorted_candidates), 200

    except Exception as e:
        logging.error(f"Error retrieving top candidates: {str(e)}")
        return jsonify({"error": str(e)}), 500





#get jobs for home page
@app.route('/get_filtered_jobs', methods=['GET'])
def get_filtered_jobs():
    try:
        cursor = mysql.connection.cursor()
        cursor.execute("""
            SELECT jobID, title, department, requiredSkills, experienceYears, education, description
            FROM Job
            WHERE status = 'open'
        """)
        jobs = cursor.fetchall()
        cursor.close()

        # Convert results to a list of dictionaries
        result = [
            {
                "jobID": job[0],
                "title": job[1],
                "department": job[2],
                "requiredSkills": job[3],
                "experienceYears": job[4],
                "education": job[5],
                "description": job[6]
            }
            for job in jobs
        ]

        logging.info("Filtered jobs retrieved successfully.")
        return jsonify(result), 200
    except Exception as e:
        logging.error(f"Error retrieving filtered jobs: {str(e)}")
        return jsonify({"error": str(e)}), 500



# get my appplications
@app.route('/get_my_applications', methods=['POST'])
def get_my_applications():
    data = request.get_json()
    candidate_id = data.get('candidateID')

    if not candidate_id:
        return jsonify({"error": "candidateID is required"}), 400

    try:
        cursor = mysql.connection.cursor()

        # Fetch applications for the given candidateID
        cursor.execute("""
            SELECT jobapplication.jobID, jobapplication.status, job.title AS jobTitle,
                   job.department, job.description, job.requiredSkills,
                   job.experienceYears, job.education
            FROM jobapplication
            INNER JOIN job ON jobapplication.jobID = job.jobID
            WHERE jobapplication.candidateID = ?
        """, (candidate_id,))
        applications = cursor.fetchall()

        # Convert query results to a list of dictionaries
        results = [dict(app) for app in applications]

        conn.close()
        return jsonify(results), 200

    except Exception as e:
        print(f"Error: {e}")
        return jsonify({"error": "An error occurred"}), 500






#sort CVs
def extract_resume_text(file_path):
    """
    Extract text from a PDF file using pdfplumber.
    """
    try:
        with pdfplumber.open(file_path) as pdf:
            text = ''.join([page.extract_text() for page in pdf.pages if page.extract_text()])
        return text.strip()
    except Exception as e:
        logging.error(f"Error extracting text from PDF: {e}")
        return ""


def sbert_sort_resumes(job_description, ):
    """
    Use Sentence-BERT to rank resumes based on a jresumesob description.
    """
    try:
        # Encode the job description
        job_embedding = sbert_model.encode(job_description, convert_to_tensor=True)

        # Encode all resumes
        resume_embeddings = sbert_model.encode(resumes, convert_to_tensor=True)

        # Compute cosine similarity scores
        similarities = util.pytorch_cos_sim(job_embedding, resume_embeddings)

        # Prepare the results with scores
        results = [{"resume": resumes[i], "score": float(similarities[0][i])} for i in range(len(resumes))]

        # Sort resumes by score (descending order)
        sorted_results = sorted(results, key=lambda x: x['score'], reverse=True)

        return sorted_results

    except Exception as e:
        logging.error(f"Error using Sentence-BERT: {e}")
        return []


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

        resumes = []
        application_data = []

        # Process resumes
        for app in applications:
            cleaned_path = os.path.basename(app[1]).replace("\\", "/")
            file_url = f"{BASE_URL}{UPLOAD_FOLDER}/{cleaned_path}"
            application_data.append({"applicationID": app[0], "name": app[2], "cvPath": file_url})
            logging.info(f"Processing resume from URL: {file_url}")

            try:
                # Download and read the resume file
                response = requests.get(file_url)
                response.raise_for_status()

                # Save the resume temporarily
                temp_filename = f"temp_{app[0]}.pdf"
                with open(temp_filename, "wb") as temp_file:
                    temp_file.write(response.content)

                # Extract text from the resume
                text = extract_resume_text(temp_filename)
                if text:
                    resumes.append(text)
                else:
                    logging.warning(f"Resume text is empty for applicationID {app[0]}.")

                # Remove the temporary file
                os.remove(temp_filename)

            except Exception as e:
                logging.error(f"Error processing file {file_url}: {e}")

        if not resumes:
            logging.error("No resumes could be read. Check the file paths or formats.")
            return jsonify({"error": "No resumes could be read."}), 400

        # Use Sentence-BERT to sort resumes
        logging.info("Sending resumes to S-BERT for sorting...")
        sorted_resumes = sbert_sort_resumes(job_description, resumes)

        if not sorted_resumes:
            logging.error("S-BERT returned no results. Check the job description or resumes.")
            return jsonify({"error": "S-BERT returned no results."}), 500

        # Combine sorted resumes with application data
        response = [
            {
                "applicationID": application_data[i]["applicationID"],
                "name": application_data[i]["name"],
                "cvPath": application_data[i]["cvPath"],
                "score": sorted_resumes[i]["score"]
            }
            for i in range(len(sorted_resumes))
        ]

        logging.info("Successfully sorted applications.")
        return jsonify({"sorted_applications": response}), 200

    except Exception as e:
        logging.error(f"Error sorting applications for jobID {jobID}: {e}")
        return jsonify({"error": str(e)}), 500











if __name__ == '__main__':
    # Enable Flask development server
    app.run(debug=True, host="0.0.0.0", port=39542)


