import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'uploadCV.dart'; // Import the UploadCVPage file

class AvailableJobs extends StatefulWidget {
  const AvailableJobs({Key? key}) : super(key: key);

  @override
  _AvailableJobsState createState() => _AvailableJobsState();
}

class _AvailableJobsState extends State<AvailableJobs> {
  late Future<List<dynamic>> _jobs;

  @override
  void initState() {
    super.initState();
    _jobs = fetchJobs(); // Fetch jobs from the database when the page loads
  }

  // Function to fetch jobs from the database
  Future<List<dynamic>> fetchJobs() async {
    final url = Uri.parse("http://127.0.0.1:39542/get_open_jobs");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load jobs');
    }
  }

  // Function to fetch job details by jobID
  Future<Map<String, dynamic>> fetchJobDetails(int jobID) async {
    final url = Uri.parse("http://127.0.0.1:39542/get_job_details/$jobID");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final job = jsonDecode(response.body);
      print("Fetched Job Details: $job"); // Debugging print statement
      return job;
    } else {
      throw Exception('Failed to load job details');
    }
  }

  // Function to display job details in a dialog
  void _showJobDetails(BuildContext context, int jobID) async {
    try {
      final job = await fetchJobDetails(jobID);
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(job['title'] ?? 'Not Available'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Department: ${job['department'] ?? 'Not Available'}"),
                const SizedBox(height: 8),
                Text("Description: ${job['description'] ?? 'Not Available'}"),
                const SizedBox(height: 8),
                Text("Requirements: ${job['requirements'] ?? 'Not Available'}"),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Close"),
              ),
            ],
          );
        },
      );
    } catch (error) {
      print("Error Fetching Job Details: $error"); // Debugging print statement
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Error"),
            content: Text("Failed to load job details: $error"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Close"),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(Icons.menu),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.share),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search),
          ),
        ],
        title: const Text("Available Jobs"),
        backgroundColor: Colors.purple,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple, Colors.purpleAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: FutureBuilder<List<dynamic>>(
          future: _jobs,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No open jobs available.'));
            }

            final jobs = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: jobs.length,
              itemBuilder: (context, index) {
                final job = jobs[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: _buildJobCard(job, context),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildJobCard(Map<String, dynamic> job, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade100, Colors.purple.shade300],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            job['title'] ?? 'No Title',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            job['description'] ?? 'No Description',
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to UploadCVPage with the JobID
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UploadCVPage(
                          jobID: job['jobID'], // Pass JobID to UploadCVPage
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                  ),
                  child: const Text("Apply"),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: TextButton(
                  onPressed: () {
                    print("JobID for Details: ${job['jobID']}"); // Debugging print statement
                    _showJobDetails(context, job['jobID']);
                  },
                  child: const Text("View Details"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
