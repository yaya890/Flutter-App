import 'package:flutter/material.dart';
import 'dart:convert'; // For jsonDecode
import 'package:http/http.dart' as http; // For HTTP requests

import 'jobPostings.dart'; // Import JobPostings page
import 'interview_review_page.dart'; // Import InterviewReviewPage

class HRhomeScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const HRhomeScreen({super.key, required this.userData});

  @override
  State<HRhomeScreen> createState() => _HRhomeScreenState();
}

class _HRhomeScreenState extends State<HRhomeScreen> {
  List<dynamic> jobs = [];
  List<dynamic> interviews = [];
  bool isLoadingJobs = false;
  bool isLoadingInterviews = false;

  @override
  void initState() {
    super.initState();
    _fetchJobs();
    _fetchInterviews();
  }

  Future<void> _fetchJobs() async {
    setState(() {
      isLoadingJobs = true;
    });

    try {
      // Replace with your real endpoint or base URL
      final response = await http.get(Uri.parse('http://127.0.0.1:39542/jobs'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          jobs = data;
        });
      } else {
        debugPrint('Error fetching jobs: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Exception while fetching jobs: $e');
    } finally {
      setState(() {
        isLoadingJobs = false;
      });
    }
  }

  Future<void> _fetchInterviews() async {
    setState(() {
      isLoadingInterviews = true;
    });

    try {
      // Replace with your real endpoint or base URL
      final response = await http.get(
          Uri.parse('http://127.0.0.1:39542/get_all_candidates_invitations'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          interviews = data;
        });
      } else {
        debugPrint('Error fetching interviews: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Exception while fetching interviews: $e');
    } finally {
      setState(() {
        isLoadingInterviews = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userData = widget.userData;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () {
              Scaffold.of(context).openDrawer(); // Open the drawer
            },
          ),
        ),
        centerTitle: true,
        title: const Text(
          'Home',
          style: TextStyle(
            color: Color(0xFF4A148C), // Purple color
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // Removed the profile (person) icon here
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            onPressed: () {
              // Log-out functionality placeholder
              Navigator.pop(context);
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 125, 25, 155),
              ),
              child: Center(
                child: Text(
                  'Menu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.work, color: Color(0xFF4A148C)),
              title: const Text('Job Postings'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => JobPostings(userData: userData),
                  ),
                );
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.interpreter_mode, color: Color(0xFF4A148C)),
              title: const Text('Interviews Management'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => InterviewReviewPage()),
                );
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              Row(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.purple,
                    child: Icon(Icons.person, color: Colors.white, size: 30),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Hello,',
                        style: TextStyle(fontSize: 18, color: Colors.black54),
                      ),
                      Text(
                        'Name: ${userData['name']}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4A148C),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Open Job Posts Section
              _buildSectionHeader('Open Job Posts'), // Removed "See all Posts"
              const SizedBox(height: 10),
              _buildJobsList(),

              const SizedBox(height: 20),

              // Finished Interviews Section
              _buildSectionHeader(
                  'Finished Interviews'), // Removed "See all Interviews"
              const SizedBox(height: 10),
              _buildFinishedInterviewsList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildJobsList() {
    if (isLoadingJobs) {
      return const Center(child: CircularProgressIndicator());
    }

    if (jobs.isEmpty) {
      return const Center(child: Text("No jobs found."));
    }

    final openJobs = jobs.where((job) => job['status'] == 'open').toList();

    if (openJobs.isEmpty) {
      return const Center(child: Text("No open jobs available."));
    }

    return SizedBox(
      height: 200,
      child: Scrollbar(
        thumbVisibility: true,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: openJobs.length,
          itemBuilder: (context, index) {
            final job = openJobs[index];
            return _buildJobCard(job);
          },
        ),
      ),
    );
  }

  Widget _buildJobCard(dynamic job) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF3E5F5), Colors.white],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Job Title: ${job['title'] ?? 'N/A'}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4A148C),
            ),
          ),
          Text(
            'Status: ${job['status'] ?? 'N/A'}',
            style: const TextStyle(color: Colors.black54),
          ),
          const Spacer(),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [],
          ),
        ],
      ),
    );
  }

  Widget _buildFinishedInterviewsList() {
    if (isLoadingInterviews) {
      return const Center(child: CircularProgressIndicator());
    }

    if (interviews.isEmpty) {
      return const Center(child: Text("No interviews found."));
    }

    // Filter interviews to only show those with status == 'Interview Done'
    final finishedInterviews = interviews
        .where((interview) => interview['status'] == 'Interview Done')
        .toList();

    if (finishedInterviews.isEmpty) {
      return const Center(child: Text("No finished interviews available."));
    }

    return SizedBox(
      height: 300,
      child: ListView.builder(
        itemCount: finishedInterviews.length,
        itemBuilder: (context, index) {
          final interview = finishedInterviews[index];
          return _buildInterviewRow(interview);
        },
      ),
    );
  }

  Widget _buildInterviewRow(dynamic interview) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Job Title: ${interview['job_title'] ?? 'N/A'}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text('Candidate Name: ${interview['candidate_name'] ?? 'N/A'}'),
          Text('Status: ${interview['status'] ?? 'N/A'}'),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () {
                // "View Summary" functionality
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7A1EA1),
              ),
              child: const Text(
                'View Summary',
                style: TextStyle(color: Colors.white), // White text color
              ),
            ),
          ),
        ],
      ),
    );
  }
}
