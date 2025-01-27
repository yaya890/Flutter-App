// newJobPosting.dart
/* import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class NewJobPosting extends StatelessWidget {
  const NewJobPosting({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black),
          onPressed: () {
            // Add menu functionality here
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Colors.black),
            onPressed: () {
              // Add profile functionality here
            },
          ),
        ],
        centerTitle: true,
        title: const Text(
          'Job Posting',
          style: TextStyle(
            color: Color(0xFF4A148C),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: JobPostingForm(),
    );
  }
}

class JobPostingForm extends StatefulWidget {
  @override
  _JobPostingFormState createState() => _JobPostingFormState();
}

class _JobPostingFormState extends State<JobPostingForm> {
  // Controllers for text fields
  final titleController = TextEditingController();
  final departmentController = TextEditingController();
  final descriptionController = TextEditingController();
  final requirementsController = TextEditingController();
  final jobQuestionsController = TextEditingController();

  // Function to submit the job posting
  Future<void> submitJobPosting() async {
    // Collect data from text fields
    final jobPosting = {
      'title': titleController.text,
      'department': departmentController.text,
      'description': descriptionController.text,
      'requirements': requirementsController.text,
      'jobQuestions': jobQuestionsController.text,
      'hr_manager_id': 1, // Replace with the actual manager ID if available
    };

    try {
      // Send data to the backend
      final response = await http.post(
        Uri.parse('http://127.0.0.1:5000/add_job'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(jobPosting),
      );

      // Handle the response
      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Job posted successfully!')),
        );
        // Clear the text fields after successful submission
        titleController.clear();
        departmentController.clear();
        descriptionController.clear();
        requirementsController.clear();
        jobQuestionsController.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to post job: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            // Job Title Field
            const Text(
              'Job Title',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildTextField(controller: titleController),

            const SizedBox(height: 20),

            // Department Field
            const Text(
              'Department',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildTextField(controller: departmentController),

            const SizedBox(height: 20),

            // Description Field
            const Text(
              'Description',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildTextField(controller: descriptionController, maxLines: 4),

            const SizedBox(height: 20),

            // Requirements Field
            const Text(
              'Requirements',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildTextField(controller: requirementsController, maxLines: 4),

            const SizedBox(height: 20),

            // Job Questions Field
            const Text(
              'Job Questions',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildTextField(controller: jobQuestionsController, maxLines: 4),

            const SizedBox(height: 30),

            // Publish Button
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.6,
                height: 50,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7A1EA1), Color(0xFF4A148C)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextButton(
                  onPressed: submitJobPosting,
                  child: const Text(
                    'Publish',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({int maxLines = 1, required TextEditingController controller}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: const InputDecoration(
          border: InputBorder.none,
        ),
      ),
    );
  }
}
 */

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class NewJobPosting extends StatelessWidget {
  final Map<String, dynamic> userData;

  const NewJobPosting({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black),
          onPressed: () {
            // Add menu functionality here
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Colors.black),
            onPressed: () {
              // Add profile functionality here
            },
          ),
        ],
        centerTitle: true,
        title: const Text(
          'Job Posting',
          style: TextStyle(
            color: Color(0xFF4A148C),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: JobPostingForm(userData: userData),
    );
  }
}

class JobPostingForm extends StatefulWidget {
  final Map<String, dynamic> userData;

  const JobPostingForm({super.key, required this.userData});

  @override
  _JobPostingFormState createState() => _JobPostingFormState();
}

class _JobPostingFormState extends State<JobPostingForm> {
  // Controllers for text fields
  final titleController = TextEditingController();
  final departmentController = TextEditingController();
  final descriptionController = TextEditingController();
  final requirementsController = TextEditingController();
  final jobQuestionsController = TextEditingController();
  final statusController = TextEditingController();
  final experienceYearsController = TextEditingController();
  final educationController = TextEditingController();

  // Function to submit the job posting
  Future<void> submitJobPosting() async {
    // Collect data from text fields
    final jobPosting = {
      'title': titleController.text,
      'department': departmentController.text,
      'description': descriptionController.text,
      'required_skills': requirementsController.text,
      'job_questions': jobQuestionsController.text,
      'status': statusController.text,
      'experience_years': int.tryParse(experienceYearsController.text) ?? 0,
      'education': educationController.text,
      'user_data': widget.userData,
    };

    try {
      // Send data to the backend
      final response = await http.post(
        Uri.parse(
            'http://127.0.0.1:39542/add_job'), // Replace with your backend URL
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(jobPosting),
      );

      // Handle the response
      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Job posted successfully!')),
        );
        // Clear the text fields after successful submission
        titleController.clear();
        departmentController.clear();
        descriptionController.clear();
        requirementsController.clear();
        jobQuestionsController.clear();
        statusController.clear();
        experienceYearsController.clear();
        educationController.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to post job: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            // Job Title Field
            const Text(
              'Job Title',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildTextField(controller: titleController),

            const SizedBox(height: 20),

            // Department Field
            const Text(
              'Department',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildTextField(controller: departmentController),

            const SizedBox(height: 20),

            // Description Field
            const Text(
              'Description',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildTextField(controller: descriptionController, maxLines: 4),

            const SizedBox(height: 20),

            // Requirements Field
            const Text(
              'Requirements',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildTextField(controller: requirementsController, maxLines: 4),

            const SizedBox(height: 20),

            // Job Questions Field
            const Text(
              'Job Questions',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildTextField(controller: jobQuestionsController, maxLines: 4),

            const SizedBox(height: 20),

            // Status Field
            const Text(
              'Status',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildTextField(controller: statusController),

            const SizedBox(height: 20),

            // Experience Years Field
            const Text(
              'Experience Years',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildTextField(controller: experienceYearsController),

            const SizedBox(height: 20),

            // Education Field
            const Text(
              'Education',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildTextField(controller: educationController),

            const SizedBox(height: 30),

            // Publish Button
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.6,
                height: 50,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7A1EA1), Color(0xFF4A148C)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextButton(
                  onPressed: submitJobPosting,
                  child: const Text(
                    'Publish',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      {int maxLines = 1, required TextEditingController controller}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: const InputDecoration(
          border: InputBorder.none,
        ),
      ),
    );
  }
}
