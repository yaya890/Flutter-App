// jobPostings.dart
// jobPostings.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'applications.dart';
import 'newJobPosting.dart';
import 'HRhomeScreen.dart'; // Make sure to import your HRHomeScreen

class JobPostings extends StatefulWidget {
  const JobPostings({super.key, required this.userData}); // Receiving userData

  final Map<String, dynamic> userData; // Accepting userData as a parameter

  @override
  _JobPostingsState createState() => _JobPostingsState();
}

class _JobPostingsState extends State<JobPostings> {
  late Future<List<dynamic>> jobs;

  @override
  void initState() {
    super.initState();
    jobs = fetchJobs();
  }

  Future<List<dynamic>> fetchJobs() async {
    try {
      final response =
          await http.get(Uri.parse('http://127.0.0.1:39542/get_jobs'));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Failed to load jobs");
      }
    } catch (e) {
      throw Exception("Error fetching jobs: $e");
    }
  }

  Widget _buildJobCard(BuildContext context, dynamic job) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          colors: [
            Color.fromARGB(255, 135, 60, 146),
            Color.fromARGB(255, 240, 238, 240)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 230, 189, 235).withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            job['title'] ?? 'Job Title',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 0, 0, 0),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            job['description'] ?? 'Description not available.',
            style: const TextStyle(
                fontSize: 14, color: Color.fromARGB(255, 0, 0, 0)),
          ),
          const SizedBox(height: 8),
          Text(
            'Status: ${job['status'] ?? 'Unknown'}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 4, 4, 245),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NewJobPosting(
                          userData: widget.userData), // Passing userData
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7A1EA1),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Edit',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ApplicationsPage(jobID: job['jobID']),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7A1EA1),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'View Applications',
                  style: TextStyle(color: Colors.white),
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
        backgroundColor: Colors.purple,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
              color: Color.fromARGB(255, 255, 255, 255)), // Back arrow icon
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    HRhomeScreen(userData: widget.userData), // Pass userData
              ),
            );
          },
        ),
        centerTitle: true,
        title: const Text(
          'Job Postings',
          style: TextStyle(
            color: Color.fromARGB(255, 255, 255, 255),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: FutureBuilder<List<dynamic>>(
          future: jobs,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No jobs found.'));
            }

            final jobs = snapshot.data!;
            return ListView.builder(
              itemCount: jobs.length,
              itemBuilder: (context, index) {
                final job = jobs[index];
                return _buildJobCard(context, job);
              },
            );
          },
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color.fromARGB(255, 154, 73, 195),
              Color.fromARGB(255, 112, 67, 203)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(25),
        ),
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NewJobPosting(
                    userData:
                        widget.userData), // Passing userData to the next screen
              ),
            );
          },
          backgroundColor: const Color.fromARGB(255, 141, 4, 200),
          elevation: 0,
          label: Text(
            '+ New Job Post',
            style: TextStyle(
                color: Colors.white), // Correctly setting text color here
          ),
        ),
      ),
    );
  }
}
