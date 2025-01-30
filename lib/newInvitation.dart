// newInvitation.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class NewInvitation extends StatelessWidget {
  const NewInvitation({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const JobPostings()),
            );
          },
        ),
        centerTitle: true,
        title: const Text(
          'New Invitation',
          style: TextStyle(
            color: Color(0xFF4A148C),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: const InvitationForm(),
    );
  }
}

class JobPostings extends StatelessWidget {
  const JobPostings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Postings'),
      ),
      body: const Center(
        child: Text('This is the Job Postings screen'),
      ),
    );
  }
}

class InvitationForm extends StatefulWidget {
  const InvitationForm({super.key});

  @override
  _InvitationFormState createState() => _InvitationFormState();
}

class _InvitationFormState extends State<InvitationForm> {
  final commentController = TextEditingController();
  String? selectedJobID;
  List<Map<String, dynamic>> jobList = [];
  DateTime? startDateTime;
  DateTime? endDateTime;

  @override
  void initState() {
    super.initState();
    fetchJobs();
  }

  Future<void> fetchJobs() async {
    try {
      final response =
          await http.get(Uri.parse('http://127.0.0.1:39542/get_all_jobs'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          jobList = data
              .map((job) => {'id': job['jobID'], 'title': job['title']})
              .toList();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load jobs: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching jobs: $e')),
      );
    }
  }

  Future<void> submitInvitation() async {
    if (selectedJobID == null || startDateTime == null || endDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill out all fields.')),
      );
      return;
    }

    final invitation = {
      'jobID': selectedJobID,
      'start': startDateTime!.toIso8601String(),
      'end': endDateTime!.toIso8601String(),
      'comment': commentController.text,
    };

    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:39542/add_invitation'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(invitation),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invitation added successfully!')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add invitation: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding invitation: $e')),
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
            const Text(
              'Select Job',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: selectedJobID,
              items: jobList
                  .map((job) => DropdownMenuItem<String>(
                        value: job['id'].toString(),
                        child: Text('${job['title']} (ID: ${job['id']})'),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedJobID = value;
                });
              },
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey.shade200,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Start Date and Time',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildDateTimePicker(
              context,
              label: startDateTime != null
                  ? startDateTime.toString()
                  : 'Select Start Date and Time',
              onPressed: () async {
                final selected = await _selectDateTime(context);
                if (selected != null) {
                  setState(() {
                    startDateTime = selected;
                  });
                }
              },
            ),
            const SizedBox(height: 20),
            const Text(
              'End Date and Time',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildDateTimePicker(
              context,
              label: endDateTime != null
                  ? endDateTime.toString()
                  : 'Select End Date and Time',
              onPressed: () async {
                final selected = await _selectDateTime(context);
                if (selected != null) {
                  setState(() {
                    endDateTime = selected;
                  });
                }
              },
            ),
            const SizedBox(height: 20),
            const Text(
              'Comment',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildTextField(controller: commentController, maxLines: 4),
            const SizedBox(height: 30),
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
                  onPressed: submitInvitation,
                  child: const Text(
                    'Save',
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

  Widget _buildDateTimePicker(BuildContext context,
      {required String label, required VoidCallback onPressed}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        title: Text(label),
        trailing: const Icon(Icons.calendar_today, color: Colors.grey),
        onTap: onPressed,
      ),
    );
  }

  Future<DateTime?> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        return DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
      }
    }

    return null;
  }
}
