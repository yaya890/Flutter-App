// available_jobs.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'uploadCV.dart'; // Import the UploadCVPage file
import 'candidate_home_screen.dart';

class AvailableJobs extends StatefulWidget {
  const AvailableJobs({super.key, required this.userData});

  final Map<String, dynamic> userData; // Accept userData as a parameter

  @override
  _AvailableJobsState createState() => _AvailableJobsState();
}

class _AvailableJobsState extends State<AvailableJobs> {
  List<dynamic> _filteredJobs = [];
  late Future<List<dynamic>> _jobs;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _jobs = fetchJobs(); // Fetch jobs from the database when the page loads
  }

  // Function to fetch jobs from the database
  Future<List<dynamic>> fetchJobs() async {
    final url = Uri.parse("http://127.0.0.1:39542/get_filtered_jobs");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load jobs');
    }
  }

  // Function to display job details in a dialog
  void _showJobDetails(BuildContext context, Map<String, dynamic> job) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(job['title'] ?? 'Not Available'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Department: ${job['department'] ?? 'Not Available'}"),
                const SizedBox(height: 8),
                Text(
                    "Required Skills: ${job['requiredSkills'] ?? 'Not Available'}"),
                const SizedBox(height: 8),
                Text("Experience: ${job['experienceYears']} years"),
                const SizedBox(height: 8),
                Text("Education: ${job['education'] ?? 'Not Available'}"),
                const SizedBox(height: 8),
                Text("Description: ${job['description'] ?? 'Not Available'}"),
              ],
            ),
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
                    // Pass both userData and jobID to UploadCVPage
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UploadCVPage(
                          userData: widget.userData, // Pass userData
                          jobID: job['jobID'], // Pass jobID
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
                    _showJobDetails(context, job);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => CandidateHomeScreen(
                  userData:
                      widget.userData, // Pass userData to CandidateHomeScreen
                ),
              ),
            );
          },
        ),
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
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: "Search jobs by title...",
                  prefixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () async {
                      final query = _searchController.text.trim();
                      if (query.isNotEmpty) {
                        setState(() {}); // Update the state with filtered jobs
                      }
                    },
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Expanded(
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

                  final jobs =
                      _searchQuery.isNotEmpty ? _filteredJobs : snapshot.data!;
                  if (jobs.isEmpty) {
                    return const Center(
                        child: Text('No jobs match your search.'));
                  }
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
          ],
        ),
      ),
    );
  }
}
