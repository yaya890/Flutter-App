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
  List<dynamic> _jobs = []; // List to store all jobs
  List<dynamic> _filteredJobs = []; // List to store filtered jobs
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  bool _isLoading = true; // Track loading state
  String? _errorMessage; // Track error messages

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _fetchJobs(); // Fetch jobs from the database when the page loads
  }

  // Function to fetch jobs from the database
  Future<void> _fetchJobs() async {
    try {
      final url = Uri.parse("http://127.0.0.1:39542/get_filtered_jobs");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        setState(() {
          _jobs = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load jobs');
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Failed to load jobs: $e";
        _isLoading = false;
      });
    }
  }

  // Function to search jobs by title
  Future<void> _searchJobs(String query) async {
    try {
      final url = Uri.parse("http://127.0.0.1:39542/search_job?title=$query");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        setState(() {
          _filteredJobs = jsonDecode(response.body);
          _searchQuery = query;
        });
      } else {
        throw Exception('Failed to search jobs');
      }
    } catch (e) {
      _showErrorDialog(context, "Failed to search jobs: $e");
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

  // Function to display an error dialog
  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Error"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
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
              color: Colors.deepPurple,
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
                    backgroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text("Apply",
                      style: TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: TextButton(
                  onPressed: () {
                    _showJobDetails(context, job);
                  },
                  child: const Text("View Details",
                      style: TextStyle(color: Colors.deepPurple)),
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
          icon: const Icon(Icons.arrow_back, color: Colors.white),
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
        title: const Text(
          "Available Jobs",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.deepPurple,
              Colors.purpleAccent,
            ],
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
                    icon: const Icon(Icons.search, color: Colors.deepPurple),
                    onPressed: () async {
                      final query = _searchController.text.trim();
                      if (query.isNotEmpty) {
                        await _searchJobs(query);
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
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                  : _errorMessage != null
                      ? Center(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(color: Colors.white),
                          ),
                        )
                      : (_searchQuery.isNotEmpty ? _filteredJobs : _jobs)
                              .isEmpty
                          ? const Center(
                              child: Text(
                                'No jobs available.',
                                style: TextStyle(color: Colors.white),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16.0),
                              itemCount: _searchQuery.isNotEmpty
                                  ? _filteredJobs.length
                                  : _jobs.length,
                              itemBuilder: (context, index) {
                                final job = _searchQuery.isNotEmpty
                                    ? _filteredJobs[index]
                                    : _jobs[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16.0),
                                  child: _buildJobCard(job, context),
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
