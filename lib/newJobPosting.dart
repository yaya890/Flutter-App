// newJobPosting.dart
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
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
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
  final titleController = TextEditingController();
  final departmentController = TextEditingController();
  final descriptionController = TextEditingController();
  final requirementsController = TextEditingController();
  final jobQuestionsController = TextEditingController();
  final statusController = TextEditingController();
  final experienceYearsController = TextEditingController();
  final educationController = TextEditingController();

  Future<void> submitJobPosting() async {
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
      final response = await http.post(
        Uri.parse('http://127.0.0.1:39542/add_job'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(jobPosting),
      );

      final responseBody = jsonDecode(response.body);

      _showResponseDialog(
        context: context,
        title: response.statusCode == 200 ? 'Success' : 'Error',
        content:
            responseBody['message'] ?? responseBody['error'] ?? 'Unknown error',
      );
    } catch (e) {
      _showResponseDialog(
        context: context,
        title: 'Error',
        content: 'Exception occurred: $e',
      );
    }
  }

  void _showResponseDialog({
    required BuildContext context,
    required String title,
    required String content,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFormField('Job Title', titleController),
            _buildFormField('Department', departmentController),
            _buildFormField('Description', descriptionController, maxLines: 4),
            _buildFormField('Requirements', requirementsController,
                maxLines: 4),
            _buildFormField('Job Questions', jobQuestionsController,
                maxLines: 4),
            _buildFormField('Status', statusController),
            _buildFormField('Experience Years', experienceYearsController),
            _buildFormField('Education', educationController),
            _buildPublishButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildFormField(String label, TextEditingController controller,
      {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            decoration: const InputDecoration(border: InputBorder.none),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildPublishButton() {
    return Center(
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
    );
  }
}
