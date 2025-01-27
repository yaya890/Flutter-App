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
from MySQLdb.cursors import DictCursor  # Ensure DictCursor is imported

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

from flask import Flask, request, jsonify, session, make_response
from flask_session import Session  # Import the Session class
import secrets
from datetime import timedelta
from flask_jwt_extended import JWTManager, create_access_token, jwt_required, get_jwt_identity
import datetime
from flask_jwt_extended import JWTManager



import random
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart


import bcrypt

from flask_bcrypt import Bcrypt




from supabase import create_client, Client


SUPABASE_URL = "https://gxfktitynhoajtnnflkr.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imd4Zmt0aXR5bmhvYWp0bm5mbGtyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTczNzU0ODM5MywiZXhwIjoyMDUzMTI0MzkzfQ.CBtp1NriHxr2QgPZOrRtIj1_VULhkX1L7wgDSKGHMxw"
supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)


try:
    # Test query: Fetch the first row from the 'user' table
    response = supabase.table('user').select("*").limit(1).execute()

    if response.data:
        print("Connection successful! Data:", response.data)
    else:
        print("Connection successful, but no data found in 'user' table.")
except Exception as e:
    print("Error connecting to Supabase:", e)


# SMTP Configuration (use your email service provider's SMTP details)
SMTP_SERVER = 'smtp.gmail.com'  # Replace with your SMTP server
SMTP_PORT = 587
EMAIL_ADDRESS = 'ElipsHR1@gmail.com'  # Replace with your email address
EMAIL_PASSWORD = 'dzxe edup suqd wrrt'  # Replace with your email password

# In-memory storage for demo purposes
verification_codes = {}






# Generate a key
secret_key = secrets.token_hex(32)

# Save it to a file
with open('secret_key.txt', 'w') as f:
    f.write(secret_key)

    # Read the key from the file
with open('secret_key.txt', 'r') as f:
    secret_key = f.read().strip()


#open ai key
openai.api_key = "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"


# Initialize Flask app
app = Flask(__name__)
bcrypt = Bcrypt(app) 
# Hash a password
password = "mySecurePassword"
hashed_password = bcrypt.generate_password_hash(password).decode('utf-8')

print("Hashed Password:", hashed_password)

# Verify the password
if bcrypt.check_password_hash(hashed_password, "mySecurePassword"):
    print("Password is correct!")
else:
    print("Invalid password.")

#get secret key - for sessions
app.secret_key = secret_key

logging.basicConfig(level=logging.DEBUG)

# Enable CORS for all routes (adjust origins if needed)
#CORS(app, resources={r"/*": {"origins": "*"}})


# Enable CORS and allow credentials
CORS(app, resources={r"/*": {"origins": "*"}}, supports_credentials=True)

# Configure session behavior
app.config['SESSION_COOKIE_HTTPONLY'] = True
app.config['SESSION_COOKIE_SECURE'] = False  # True if using HTTPS
app.config['SESSION_COOKIE_SAMESITE'] = 'Lax'

# app.config['PERMANENT_SESSION_LIFETIME'] = timedelta(minutes=360)  # Session timeout

# Import Flask-Session if needed (uncomment if using server-side sessions like Redis)
# from flask_session import Session
# Session(app)


# Configure MySQL connection
app.config['MYSQL_HOST'] = 'localhost'  # Replace 'localhost' with your public IP address
app.config['MYSQL_USER'] = 'root'            # Your MySQL username
app.config['MYSQL_PASSWORD'] = 'yara'        # Your MySQL password
app.config['MYSQL_DB'] = 'ElpisHR'           # Your database name



# Configure JWT
app.config['JWT_SECRET_KEY'] = 'cad071e5f10059c4f2b1db3b78e97a3eaa5a9c7fbffbc40c1c4b80c328767513'  # Use a secure key
app.config['JWT_ACCESS_TOKEN_EXPIRES'] = datetime.timedelta(hours=1)  # Token expiration time
jwt = JWTManager(app)


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




@app.route('/signup', methods=['POST'])
def signup():
    try:
        # Parse the JSON request
        data = request.get_json()
        name = data.get('name')
        email = data.get('email')
        password = data.get('password')
        role = data.get('role')

        # Validate input
        if not name or not email or not password or not role:
            return jsonify({'error': 'All fields are required.'}), 400

        # Generate a 4-digit verification code
        verification_code = str(random.randint(1000, 9999))

        # Send the verification code via email
        if not send_verification_email(email, verification_code):
            return jsonify({'error': 'Failed to send verification email.'}), 500

        # Store the verification code (this should be replaced with database storage in production)
        verification_codes[email] = verification_code

        # Respond with success and return the verification code for demonstration purposes
        return jsonify({
            'message': 'Sign-up successful. Verification code sent to email.',
            'verification_code': verification_code
        }), 200

    except Exception as e:
        return jsonify({'error': str(e)}), 500

def send_verification_email(to_email, code):
    try:
        # Create the email content
        subject = "Your Verification Code"
        body = f"Your verification code is: {code}"

        # Set up the email
        msg = MIMEMultipart()
        msg['From'] = EMAIL_ADDRESS
        msg['To'] = to_email
        msg['Subject'] = subject
        msg.attach(MIMEText(body, 'plain'))

        # Connect to the SMTP server and send the email
        server = smtplib.SMTP(SMTP_SERVER, SMTP_PORT)
        server.starttls()
        server.login(EMAIL_ADDRESS, EMAIL_PASSWORD)
        server.send_message(msg)
        server.quit()

        return True
    except Exception as e:
        print(f"Error sending email: {e}")
        return False


# verfication
@app.route('/verify', methods=['POST'])
def verify():
    try:
        # Parse the JSON request
        data = request.get_json()
        email = data.get('email')
        code = data.get('code')

        # Validate input
        if not email or not code:
            return jsonify({'error': 'Email and code are required.'}), 400

        # Check if the email exists in the stored verification codes
        if email not in verification_codes:
            return jsonify({'error': 'Verification code not found for this email.'}), 404

        # Check if the code matches
        if verification_codes[email] == code:
            del verification_codes[email]  # Delete the code after successful verification
            return jsonify({'message': 'Verification successful.'}), 200
        else:
            return jsonify({'error': 'Invalid verification code.'}), 400

    except Exception as e:
        return jsonify({'error': str(e)}), 500


#Store new user 
@app.route('/store_new_user', methods=['POST'])
def store_new_user():
    try:
        # Parse the JSON request
        data = request.get_json()
        name = data.get('name')
        email = data.get('email')
        password = data.get('password')
        role = data.get('role')

        # Validate input
        if not name or not email or not password or not role:
            return jsonify({'error': 'All fields are required.'}), 400

        # Hash the password
        hashed_password = bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt())

        # Insert user into the Supabase database
        response = supabase.table('user').insert({
            'name': name,
            'email': email,
            'password': hashed_password.decode('utf-8'),  # Decode to store as a string
            'role': role
        }).execute()

        # Check response status
        if response.status_code == 201:
            return jsonify({'message': 'User stored successfully.'}), 201
        else:
            return jsonify({'error': 'Failed to store user.'}), 500

    except Exception as e:
        return jsonify({'error': str(e)}), 500


#welcome page
@app.route('/write_role', methods=['POST'])
def write_role():
    try:
        # Get the role from the request body
        data = request.json
        role = data.get('role')

        if not role:
            return jsonify({"error": "Role is required"}), 400

        # Path to the user_data.txt file
        file_path = os.path.join('backend', 'uploads', 'user_data.txt')

        # Write the role to the file
        with open(file_path, 'w') as file:
            file.write(f'role: {role}\n')

        return jsonify({"message": "Role written successfully"}), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500



@app.route('/login', methods=['POST'])
def login():
    data = request.json
    email = data.get('email')
    password = data.get('password')
    role = data.get('role')  # Role passed from the Flutter app

    # Check for missing fields
    if not email or not password or not role:
        return jsonify({"error": "Missing fields"}), 400

    # Query Supabase for user
    response = supabase.table('user').select("*").eq('email', email).execute()
    user = response.data

    if not user:
        return jsonify({"error": "User not found"}), 404

    user = user[0]  # Get the first user (assuming email is unique)

    # Verify password
    if not bcrypt.check_password_hash(user['password'], password):  # Ensure passwords are hashed in Supabase
        return jsonify({"error": "Invalid password"}), 401

    # Verify role
    if user['role'].lower() != role.lower():
        return jsonify({"error": "Role mismatch"}), 403

    # Return user data
    return jsonify({
        "name": user['name'],
        "email": user['email'],
        "role": user['role'],
    }), 200






# /add_job Endpoint
@app.route('/add_job', methods=['POST'])
def add_job():
    data = request.json
    title = data.get('title')
    department = data.get('department')
    description = data.get('description')
    requirements = data.get('required_skills')
    job_questions = data.get('job_questions', "")
    status = data.get('status')
    experience_years = data.get('experience_years', 0)  # Default to 0 if not provided
    education = data.get('education')
    user_data = data.get('user_data', {})

    # Check for missing fields
    if not all([title, department, description, requirements, status, education, user_data.get('email')]):
        return jsonify({"error": "Missing fields"}), 400

    # Extract the email from user_data
    email = user_data.get('email')

    # Query Supabase for user_id based on email
    response = supabase.table('user').select('user_id').eq('email', email).execute()
    user = response.data

    if not user:
        return jsonify({"error": "User not found"}), 404

    user_id = user[0]['user_id']
    
    # Query Supabase for hr_id based on user_id
    hr_response = supabase.table('hrmanager').select('hr_id').eq('user_id', user_id).execute()
    hr_result = hr_response.data

    if not hr_result:
        return jsonify({"error": "HR manager not found"}), 404

    hr_id = hr_result[0]['hr_id']

    # Prepare the job data
    job_data = {
        'title': title,
        'department': department,
        'description': description,
        'required_skills': requirements,
        'job_questions': job_questions,
        'status': status,
        'hr_id': hr_id,
        'experience_years': experience_years,
        'education': education
    }

    # Insert job into Job table
    response = supabase.table('job').insert(job_data).execute()

    if not response.data:
        return jsonify({"error": "Failed to add job"}), 500

    return jsonify({"message": "Job added successfully"}), 200



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
    email = data.get('email')

    # Step 1: Fetch user_id from the user table
    user_response = supabase.table("user").select("user_id").eq("email", email).execute()
    user_id = user_response.data[0]['user_id']

    # Step 2: Fetch candidate_id from the candidate table
    candidate_response = supabase.table("candidate").select("candidate_id").eq("user_id", user_id).execute()
    candidate_id = candidate_response.data[0]['candidate_id']

    # Step 3: Insert application into the jobapplication table
    supabase.table("jobapplication").insert({
        "candidate_id": candidate_id,
        "job_id": job_id,
        "cv_path": cv_file_path,
        "status": "Application Sent"
    }).execute()

    # Return success message
    return jsonify({"message": "Application saved successfully"}), 201











# get user id for candidate home screen 
@app.route('/get_user_id', methods=['POST'])
def get_user_id():
    data = request.json
    email = data.get('email')
    
    if not email:
        logging.error("Email is required")
        return jsonify({"error": "Email is required"}), 400

    try:
        # Query Supabase to get the user with the provided email
        response = supabase.table('user').select('user_id').eq('email', email).execute()

        if response.data:
            user_id = response.data[0]['userID']
            logging.info(f"User found: {email}, UserID: {user_id}")
            return jsonify({"userID": user_id}), 200
        else:
            logging.error(f"User not found with email: {email}")
            return jsonify({"error": "User not found"}), 404
    except Exception as e:
        logging.error(f"Error fetching user ID: {str(e)}")
        return jsonify({"error": "An error occurred while fetching user ID"}), 500


#display job posts
@app.route('/get_jobs', methods=['GET'])
def get_jobs():
    try:
        # Query jobs from the 'job' table, ordered by job_id in descending order
        response = supabase.table('job').select(
            'job_id, title, description, status'
        ).order('job_id', desc=True).execute()

        

        jobs = response.data

        # Convert results to a list of dictionaries
        result = [{"jobID": job['job_id'],
                    "title": job['title'],
                    "description": job['description'],
                    "status": job['status']} for job in jobs]

        return jsonify(result), 200
    except Exception as e:
        logging.error(f"Error retrieving jobs: {str(e)}")
        return jsonify({"error": str(e)}), 500



# Get Applications Endpoint
@app.route('/get_application/<int:jobID>', methods=['GET'])
def get_application(jobID):
    try:
        # Query Supabase to get the applications for the given jobID
        response = supabase.table('jobapplication').select(
            'application_id, cv_path, candidate_id'
        ).eq('job_id', jobID).execute()

        applications = response.data

        if not applications:
            logging.warning(f"No applications found for JobID: {jobID}")
            return jsonify({"message": "No applications found", "data": []}), 200

        # Build result list
        result = []
        for app in applications:
            # Fetch candidate's user_id
            candidate_response = supabase.table('candidate').select(
                'user_id'
            ).eq('candidate_id', app['candidate_id']).execute()

            candidate_data = candidate_response.data
            if not candidate_data:
                continue  # If no candidate found, skip this application

            user_id = candidate_data[0]['user_id']

            # Fetch the user's name using the user_id
            user_response = supabase.table('user').select(
                'name'
            ).eq('user_id', user_id).execute()

            user_data = user_response.data
            if not user_data:
                continue  # If no user found, skip this application

            user_name = user_data[0]['name']

            # Clean the CV path
            cleaned_path = os.path.basename(app['cv_path']).replace("\\", "/")
            result.append({
                "applicationID": app['application_id'],
                "cvPath": f"{BASE_URL}{UPLOAD_FOLDER}/{cleaned_path}",
                "name": user_name
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
    email = request.args.get('email')  # Retrieve email from query parameters

    # Check for missing email
    if not email:
        return jsonify({"error": "Missing email"}), 400

    # Step 1: Fetch the user based on email
    user_response = supabase.table("user").select("user_id").eq("email", email).execute()
    user_data = user_response.data

    if not user_data:
        return jsonify({"error": "User not found"}), 404

    user_id = user_data[0]["user_id"]  # Get the user_id

    # Step 2: Fetch the candidate based on user_id
    candidate_response = supabase.table("candidate").select("candidate_id").eq("user_id", user_id).execute()
    candidate_data = candidate_response.data

    if not candidate_data:
        return jsonify({"error": "Candidate not found"}), 404

    candidate_id = candidate_data[0]["candidate_id"]

    # Step 3: Fetch job applications with invitations
    job_applications_response = (
        supabase.table("jobapplication")
        .select("invitation_id, job_id")
        .eq("candidate_id", candidate_id)
        .execute()
    )
    job_applications = job_applications_response.data

    if not job_applications:
        return jsonify({"invitations": []}), 200  # No invitations found, return empty list

    invitations = []

    # Step 4: Fetch details for each invitation
    for application in job_applications:
        invitation_id = application["invitation_id"]
        job_id = application["job_id"]

        # Fetch interview invitation details
        invitation_response = supabase.table("interview_invitation").select(
            "start_time, end_time, comment, invitation_id"
        ).eq("invitation_id", invitation_id).execute()

        invitation_data = invitation_response.data
        if not invitation_data:
            continue

        # Fetch the job title
        job_response = supabase.table("job").select("title").eq("job_id", job_id).execute()
        job_data = job_response.data
        if not job_data:
            continue

        # Add invitation details to the response
        invitations.append({
            "title": job_data[0]["title"],
            "start": invitation_data[0]["start_time"],
            "end": invitation_data[0]["end_time"],
            "comment": invitation_data[0]["comment"],
            "invitation_id": invitation_data[0]["invitation_id"],
        })

    return jsonify({"invitations": invitations}), 200





# HR invitations route
@app.route('/interview_invitations', methods=['GET'])
def get_interview_invitations():
    # Fetch all interview invitations
    invitations = supabase.table('interview_invitation').select('*').execute().data
    result = []

    for invitation in invitations:
        # Fetch the job_id from the invitation
        job_id = invitation.get('job_id')
        
        if job_id is None:  # Check if job_id is None
            print(f"Skipping invitation with missing job_id: {invitation['invitation_id']}")
            continue  # Skip invitations with missing job_id
        
        # Fetch the job from the job table using job_id
        job = supabase.table('job').select('title').eq('job_id', job_id).execute().data
        
        # Debugging logs to check what's being returned
        print(f"job_id: {job_id}, job: {job}")  # Log job_id and job data

        if job:  # If job exists
            result.append({
                "invitation_id": invitation['invitation_id'],
                "jobID": job_id,
                "title": job[0]['title'],  # Get the title of the job
                "start": invitation['start_time'],
                "end": invitation['end_time'],
                "comment": invitation['comment']
            })
        else:
            print(f"Job not found for job_id: {job_id}")  # Log if job is not found

    return jsonify(result)












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

        # Print the invitationID for debugging
        print(f"Received invitationID: {invitation_id}")

        if not invitation_id:
            return jsonify({"error": "invitationID is required"}), 400

        # Step 1: Get jobID from interview_invitation table
        invitation_response = supabase.table("interview_invitation").select("job_id").eq("invitation_id", invitation_id).execute()
        if not invitation_response.data:
            return jsonify({"error": "No job found for the provided invitationID"}), 404

        job_id = invitation_response.data[0]['job_id']

        # Step 2: Get job details from the job table
        job_response = supabase.table("job").select("title, department, description, job_questions, required_skills, experience_years, education").eq("job_id", job_id).execute()
        if not job_response.data:
            return jsonify({"error": "No job details found for the provided job_id"}), 404

        job_data = job_response.data[0]

        # Extract job details
        title = job_data['title']
        department = job_data['department']
        description = job_data['description']
        job_questions_raw = job_data['job_questions']
        required_skills = job_data['required_skills']
        experience_years = job_data['experience_years']
        education = job_data['education']

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
        invitation_id = data.get('invitationID')
        user_data = data.get('userData')  # Add user data for identifying the user

        # Validate required fields
        if not user_message:
            return jsonify({"error": "Missing field: 'message'"}), 400
        if not job_details:
            return jsonify({"error": "Missing field: 'jobDetails'"}), 400
        if current_question_index is None:
            return jsonify({"error": "Missing field: 'currentQuestionIndex'"}), 400
        if not job_questions:
            return jsonify({"error": "Missing field: 'jobQuestions'"}), 400
        if not user_data:
            return jsonify({"error": "Missing field: 'userData'"}), 400

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

        # If chat is ending, generate the summary and update the job application status
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

            # Extract email from user_data
            email = user_data.get('email')
            if not email:
                return jsonify({"error": "Missing field: 'email' in userData"}), 400

            # Query the user table to get user_id
            user_response = supabase.from_('user').select('user_id').eq('email', email).execute()
            if not user_response.data:
                return jsonify({"error": "User not found"}), 404
            user_id = user_response.data[0]['user_id']

            # Query the candidate table to get candidate_id
            candidate_response = supabase.from_('candidate').select('candidate_id').eq('user_id', user_id).execute()
            if not candidate_response.data:
                return jsonify({"error": "Candidate not found"}), 404
            candidate_id = candidate_response.data[0]['candidate_id']

            # Query the jobapplication table to get application_id
            job_application_response = supabase.from_('jobapplication').select('application_id').eq('candidate_id', candidate_id).eq('invitation_id', invitation_id).execute()
            if not job_application_response.data:
                return jsonify({"error": "Job application not found"}), 404
            application_id = job_application_response.data[0]['application_id']

            # Insert the summary into the chatbot table
            supabase.from_('chatbot').insert({
                'invitation_id': invitation_id,
                'summary': summary,
                'application_id': application_id
            }).execute()

            # Update the job application status to "Interview Done"
            supabase.from_('jobapplication').update({
                'status': 'Interview Done'
            }).eq('application_id', application_id).execute()

        return jsonify({
            "bot_message": bot_message,
            "currentQuestionIndex": current_question_index,
            "chat_history": chat_history,
            "is_chat_ending": is_chat_ending
        }), 200

    except Exception as e:
        logging.error(f"Error in /send_message: {str(e)}")
        return jsonify({"error": str(e)}), 500
    
    
    
    
    
    
    
    
    
    
@app.route('/get_candidate_summary', methods=['GET'])
def get_candidate_summary():
    try:
        # Get invitation_id and application_id from query parameters
        invitation_id = request.args.get('invitation_id')
        application_id = request.args.get('application_id')

        # Validate required fields
        if not invitation_id or not application_id:
            return jsonify({"error": "Missing required fields: 'invitation_id' and 'application_id'"}), 400

        # Query the chatbot table for the matching row
        response = supabase.from_('chatbot').select('summary').eq('invitation_id', invitation_id).eq('application_id', application_id).execute()

        # Check if data was found
        if not response.data:
            return jsonify({"error": "No summary found for the provided invitation_id and application_id"}), 404

        # Extract the summary from the response
        summary = response.data[0]['summary']

        # Return the summary in the response
        return jsonify({"summary": summary}), 200

    except Exception as e:
        return jsonify({"error": str(e)}), 500

    
    
    
    
    
    
    
    
    
    
    
@app.route('/get_all_candidates_invitations', methods=['GET'])
def get_all_candidates_invitations():
    try:
        # Query the jobapplication table to get rows with non-null invitation_id
        job_applications_response = supabase.from_('jobapplication').select('*').not_.is_('invitation_id', 'null').execute()
        job_applications = job_applications_response.data

        if not job_applications:
            return jsonify({"message": "No invitations found"}), 200

        result = []

        for application in job_applications:
            invitation_id = application['invitation_id']
            job_id = application['job_id']
            status = application['status']
            candidate_id = application['candidate_id']
            application_id = application['application_id']

            # Query the job table to get the job title
            job_response = supabase.from_('job').select('title').eq('job_id', job_id).execute()
            if not job_response.data:
                continue  # Skip if job not found
            job_title = job_response.data[0]['title']

            # Query the chatbot table to get the summary using invitation_id
            chatbot_response = supabase.from_('chatbot').select('summary').eq('invitation_id', invitation_id).execute()
            summary = chatbot_response.data[0]['summary'] if chatbot_response.data else None

            # Query the candidate table to get the user_id
            candidate_response = supabase.from_('candidate').select('user_id').eq('candidate_id', candidate_id).execute()
            if not candidate_response.data:
                continue  # Skip if candidate not found
            user_id = candidate_response.data[0]['user_id']

            # Query the user table to get the candidate's name
            user_response = supabase.from_('user').select('name').eq('user_id', user_id).execute()
            if not user_response.data:
                continue  # Skip if user not found
            candidate_name = user_response.data[0]['name']

            # Append the result
            result.append({
                "job_title": job_title,
                "candidate_name": candidate_name,
                "status": status,
                "invitation_id": invitation_id,
                "application_id": application_id
            })

        return jsonify(result), 200

    except Exception as e:
        logging.error(f"Error in /get_all_candidates_invitations: {str(e)}")
        return jsonify({"error": str(e)}), 500













### Endpoint 1: Fetch Jobs
@app.route('/get_all_jobs', methods=['GET'])
def get_all_jobs():
    try:
        # Fetch data from the Supabase 'job' table
        response = supabase.table('job').select('job_id, title').execute()

        # Check if any jobs were returned
        if not response.data:
            return jsonify({"error": "No jobs found"}), 404

        jobs = response.data

        # Format response as a list of dictionaries
        job_list = [{"jobID": job['job_id'], "title": job['title']} for job in jobs]

        return jsonify(job_list), 200

    except Exception as e:
        logging.error(f"Error fetching jobs: {str(e)}")
        return jsonify({"error": "An internal server error occurred"}), 500




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

        # Insert data into the 'interview_invitation' table in Supabase
        response = supabase.table('interview_invitation').insert({
            "job_id": job_id,
            "start_time": start,
            "end_time": end,
            "comment": comment
        }).execute()

        # Check if the insertion was successful
        if not response.data:
            return jsonify({"error": "Failed to add invitation"}), 500

        logging.info(f"New invitation added: jobID={job_id}, start={start}, end={end}")
        return jsonify({"message": "Invitation added successfully"}), 201

    except Exception as e:
        logging.error(f"Error adding invitation: {str(e)}")
        return jsonify({"error": "An internal server error occurred"}), 500





# get top candidates 
# Get top candidates
@app.route('/get_top_candidates', methods=['GET'])
def get_top_candidates():
    try:
        # Get jobID from query parameters
        job_id = request.args.get('jobID')
        if not job_id:
            return jsonify({"error": "jobID is required"}), 400

        # Query jobapplication table for candidates associated with the given jobID
        job_applications_response = supabase.table('jobapplication').select(
            'candidate_id, last_ranking, last_score'
        ).eq('job_id', job_id).execute()

        job_applications = job_applications_response.data

        if not job_applications:
            return jsonify({"message": "No candidates found for the given jobID"}), 404

        # Fetch candidate details
        candidates = []
        for application in job_applications:
            candidate_id = application['candidate_id']
            last_ranking = application.get('last_ranking')
            last_score = application.get('last_score')

            # Handle missing or null values
            last_ranking = last_ranking if last_ranking is not None else "not sorted"
            last_score = last_score if last_score is not None else "not sorted"

            # Query candidate table for user_id
            candidate_response = supabase.table('candidate').select('user_id').eq('candidate_id', candidate_id).execute()
            if not candidate_response.data:
                continue
            user_id = candidate_response.data[0]['user_id']

            # Query user table for name
            user_response = supabase.table('user').select('name').eq('user_id', user_id).execute()
            if not user_response.data:
                continue
            user_name = user_response.data[0]['name']

            candidates.append({
                "candidateID": candidate_id,
                "name": user_name,
                "last_ranking": last_ranking,
                "last_score": last_score
            })

        # Sort candidates by last_score (descending) and last_ranking (ascending), ignore "not sorted" during sorting
        sorted_candidates = sorted(
            candidates,
            key=lambda x: (x["last_ranking"] if x["last_ranking"] != "not sorted" else float('inf'),
                        (x["last_score"] if x["last_score"] != "not sorted" else float('-inf')))
        )

        # Add the jobID at the end of the list
        sorted_candidates.append({"jobID": job_id})

        logging.info(f"Top candidates retrieved successfully for jobID: {job_id}")
        return jsonify(sorted_candidates), 200

    except Exception as e:
        logging.error(f"Error retrieving top candidates: {str(e)}")
        return jsonify({"error": "An internal server error occurred"}), 500






#get jobs for home page
@app.route('/get_filtered_jobs', methods=['GET'])
def get_filtered_jobs():
    # Query jobs with status 'open' from the 'job' table in Supabase
    response = supabase.table('job').select(
        'job_id', 'title', 'department', 'required_skills', 'experience_years', 'education', 'description'
    ).eq('status', 'open').execute()

    # Get the jobs data
    jobs = response.data

    # If jobs are found, map and return them
    if jobs:
        result = [
            {
                "jobID": job['job_id'],
                "title": job['title'],
                "department": job['department'],
                "requiredSkills": job['required_skills'],
                "experienceYears": job['experience_years'],
                "education": job['education'],
                "description": job['description']
            }
            for job in jobs
        ]
        return jsonify(result), 200
    else:
        # If no jobs are found, return a "no jobs available" message
        return jsonify({"message": "No jobs available."}), 404





#Search job
@app.route('/search_job', methods=['GET'])
def search_job():
    try:
        # Get the search query parameter
        title_query = request.args.get('title', '').strip()
        if not title_query:
            return jsonify([])  # Return an empty list if the query is empty

        # Query the database to get all job titles
        response = supabase.table('job') \
            .select('*') \
            .execute()

        # Extract the data from the response
        jobs = response.data

        # Perform matching to find the closest matches
        matching_jobs = [
            {
                "jobID": job['job_id'],
                "title": job['title'],
                "department": job['department'],
                "requiredSkills": job['required_skills'],
                "experienceYears": job['experience_years'],
                "education": job['education'],
                "description": job['description'],
            }
            for job in jobs
            if title_query.lower() in job['title'].lower() or title_query.lower() in job['title'].lower()[:len(title_query)//2]
        ]

        return jsonify(matching_jobs)
    except Exception as e:
        print(f"Error: {e}")
        return jsonify({'error': 'An error occurred while fetching jobs'}), 500
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    #Send invite to candidate
@app.route('/send_invite', methods=['POST'])
def send_invitation():
    try:
        # Parse request data
        data = request.json
        logging.info(f"Received data: {data}")
        job_id = data.get('jobID')
        invitation_id = data.get('invitationID')
        candidate_ids = data.get('candidateIDs')

        # Validate inputs
        if not all([job_id, invitation_id, candidate_ids]) or not isinstance(candidate_ids, list):
            logging.error("Invalid input data")
            return jsonify({'error': 'Invalid input data'}), 400

        # Format candidate IDs for Supabase (use parentheses instead of square brackets)
        candidate_id_filter = f"({','.join(map(str, candidate_ids))})"

        # Update rows in Supabase
        response = supabase.table('jobapplication').update({
            'invitation_id': invitation_id,
            'status': 'Interview invitation Sent'
        }).filter('job_id', 'eq', job_id).filter('candidate_id', 'in', candidate_id_filter).execute()

        logging.info(f"Supabase response: {response}")

        # Check if the update was successful
        if not response.data:
            logging.error("No data returned from Supabase")
            return jsonify({'error': 'Failed to update records'}), 500

        return jsonify({'message': 'Invitations sent successfully', 'data': response.data}), 200

    except Exception as e:
        logging.error(f"Exception occurred: {str(e)}")
        return jsonify({'error': str(e)}), 500





# get my appplications
@app.route('/get_my_applications', methods=['POST'])
def get_my_applications():
    try:
        # Parse incoming data
        data = request.json
        print(f"Received data: {data}")  # Log the raw incoming data

        # Extract email from the userData
        user_data = data.get('userData')  # Get the userData field
        if not user_data:
            return jsonify({"error": "userData is required"}), 400
        
        user_email = user_data.get('email')  # Extract the email from userData

        # Validate required field
        if not user_email:
            return jsonify({"error": "Email is required"}), 400

        # Retrieve user_id from the user table using email
        user_response = supabase.table("user").select("user_id").eq("email", user_email).execute()
        user_data = user_response.data

        if not user_data:
            return jsonify({"error": "User not found"}), 404

        user_id = user_data[0]['user_id']

        # Retrieve candidate_id from the candidate table using user_id
        candidate_response = supabase.table("candidate").select("candidate_id").eq("user_id", user_id).execute()
        candidate_data = candidate_response.data

        if not candidate_data:
            return jsonify({"error": "Candidate not found"}), 404

        candidate_id = candidate_data[0]['candidate_id']

        # Retrieve job applications for the given candidate_id
        applications_response = supabase.table("jobapplication").select("job_id", "status").eq("candidate_id", candidate_id).execute()
        applications_data = applications_response.data

        if not applications_data:
            return jsonify({"error": "No applications found"}), 404

        # Retrieve detailed job information for each application
        results = []
        for application in applications_data:
            job_id = application['job_id']
            status = application['status']

            job_response = supabase.table("job").select("title", "department", "description", "required_skills", "experience_years", "education").eq("job_id", job_id).execute()
            job_data = job_response.data

            if job_data:
                job_info = job_data[0]
                job_info['status'] = status  # Add application status to job info
                results.append(job_info)

        return jsonify(results), 200

    except Exception as e:
        logging.error(f"Error in /get_my_applications: {str(e)}")
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

# Choose a model
sbert_model = SentenceTransformer('all-MiniLM-L6-v2')

def sbert_sort_resumes(job_description, resumes):
    """
    Use Sentence-BERT to rank resumes based on a job description.
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
    logging.info(f"Received request to sort applications for jobID: {jobID}")

    # Step 1: Fetch job requirements from Supabase
    job_response = supabase.table('job').select('required_skills', 'experience_years', 'education').eq('job_id', jobID).single().execute()
    job = job_response.data

    if not job:
        return jsonify({"error": "Job not found"}), 404

    job_description = f"""
    Required Skills: {job['required_skills'] if job.get('required_skills') else "None"}.
    Experience Years: {job['experience_years'] if job.get('experience_years') else "None"}.
    Education: {job['education'] if job.get('education') else "None"}.
    """

    # Step 2: Fetch applications for the job
    applications_response = supabase.table('jobapplication').select('application_id', 'cv_path', 'candidate_id').eq('job_id', jobID).execute()
    
    if not applications_response.data:
        return jsonify({"message": "No applications found", "data": []}), 200

    application_data = []
    resumes = []

    # Step 3: Fetch candidate details for each application
    for app in applications_response.data:
        candidate_id = app['candidate_id']
        
        # Fetch candidate info from the 'candidate' table to get the user_id
        candidate_response = supabase.table('candidate').select('user_id').eq('candidate_id', candidate_id).single().execute()
        candidate = candidate_response.data

        if not candidate:
            return jsonify({"error": f"Candidate {candidate_id} not found"}), 404

        user_id = candidate['user_id']
        
        # Fetch the user's name from the 'user' table using the user_id
        user_response = supabase.table('user').select('name').eq('user_id', user_id).single().execute()
        user = user_response.data

        if not user:
            return jsonify({"error": f"User for candidate {candidate_id} not found"}), 404
        
        name = user['name']

        # Prepare application data
        cleaned_path = os.path.basename(app['cv_path']).replace("\\", "/")
        file_url = f"{BASE_URL}{UPLOAD_FOLDER}/{cleaned_path}"
        application_data.append({"applicationID": app['application_id'], "name": name, "cvPath": file_url})

        # Download and read the resume file
        response = requests.get(file_url)
        if response.status_code != 200:
            return jsonify({"error": f"Error downloading file {file_url}"}), 500

        # Save the resume temporarily
        temp_filename = f"temp_{app['application_id']}.pdf"
        with open(temp_filename, "wb") as temp_file:
            temp_file.write(response.content)

        # Extract text from the resume
        text = extract_resume_text(temp_filename)
        if text:
            resumes.append(text)

        # Remove the temporary file
        os.remove(temp_filename)

    if not resumes:
        return jsonify({"error": "No resumes could be read."}), 400

    # Step 4: Use Sentence-BERT to sort resumes
    sorted_resumes = sbert_sort_resumes(job_description, resumes)

    if not sorted_resumes:
        return jsonify({"error": "S-BERT returned no results."}), 500

    # Step 5: Combine sorted resumes with application data
    response = [
        {
            "applicationID": application_data[i]["applicationID"],
            "name": application_data[i]["name"],
            "cvPath": application_data[i]["cvPath"],
            "score": sorted_resumes[i]["score"]
        }
        for i in range(len(sorted_resumes))
    ]

    return jsonify({"sorted_applications": response}), 200









if __name__ == '__main__':
    # Enable Flask development server
    app.run(debug=True, host="0.0.0.0", port=39542)
