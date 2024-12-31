from flask import Flask, jsonify, request
from flask_mysqldb import MySQL
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

# Configure MySQL connection
app.config['MYSQL_HOST'] = 'localhost'  # Your database host
app.config['MYSQL_USER'] = 'root'  # Your MySQL username
app.config['MYSQL_PASSWORD'] = 'Aljawharah'  # Your MySQL password
app.config['MYSQL_DB'] = 'ElpisHR'  # Your database name

mysql = MySQL(app)

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
    job_questions = data.get('jobQuestions')
    hr_manager_id = data.get('hr_manager_id', 1)  # Default to 1 if not provided

    try:
        cursor = mysql.connection.cursor()
        cursor.execute("""
            INSERT INTO Job (title, description, requirements, jobQuestions, hr_manager_id)
            VALUES (%s, %s, %s, %s, %s)
        """, (title, description, requirements, job_questions, hr_manager_id))
        mysql.connection.commit()
        cursor.close()
        return jsonify({"message": "Job added successfully"}), 201
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    app.run(debug=True, port=39542)

