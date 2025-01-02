from flask import Flask, jsonify, request
from flask_mysqldb import MySQL
from flask_cors import CORS
import logging

# Initialize Flask app
app = Flask(__name__)

# Enable CORS for all routes (adjust origins if needed)
CORS(app, resources={r"/*": {"origins": "*"}})

# Configure MySQL connection
app.config['MYSQL_HOST'] = 'localhost'  # Your database host
app.config['MYSQL_USER'] = 'root'  # Your MySQL username
app.config['MYSQL_PASSWORD'] = 'yara'  # Your MySQL password
app.config['MYSQL_DB'] = 'ElpisHR'  # Your database name

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


if __name__ == '__main__':
    # Enable Flask development server
    app.run(debug=True, host="0.0.0.0", port=39542)
