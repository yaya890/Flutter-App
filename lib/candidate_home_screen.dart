import 'package:flutter/material.dart';
import 'uploadCV.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'jobs_interview_page.dart';
import 'available_jobs.dart';

class CandidateHomeScreen extends StatefulWidget {
  final int candidateID; // Accept candidateID

  const CandidateHomeScreen({super.key, required this.candidateID});

  @override
  _CandidateHomeScreenState createState() => _CandidateHomeScreenState();
}

class _CandidateHomeScreenState extends State<CandidateHomeScreen> {
  List<dynamic> jobList = [];
  List<dynamic> applicationList = [];

  @override
  void initState() {
    super.initState();
    fetchJobs();
    fetchApplications();
  }

  Future<void> fetchJobs() async {
    final url = Uri.parse('http://127.0.0.1:39542/get_filtered_jobs');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          jobList = json.decode(response.body);
        });
      } else {
        throw Exception('Failed to load jobs');
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> fetchApplications() async {
    final url = Uri.parse('http://127.0.0.1:39542/get_my_applications');
    try {
      final response = await http.post(
        url,
        body: json.encode({"candidateID": widget.candidateID}),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        setState(() {
          applicationList = json.decode(response.body);
        });
      } else {
        throw Exception('Failed to load applications');
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Hello, John Doe"),
        backgroundColor: Colors.purple,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.purple,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.purple,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "John Doe",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "john.doe@example.com",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text("Home"),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.work),
              title: const Text("Available Jobs"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AvailableJobs(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.mail_outline),
              title: const Text("Interviews Invitations"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => JobsInterviewPage(candidateID: '1'),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text("Logout"),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            "Jobs Listings\nRecommended for you",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          jobList.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: jobList.map((job) {
                      return _buildJobCard(
                        context,
                        job['title'],
                        job['department'],
                        job['requiredSkills'],
                        job['experienceYears'],
                        job['education'],
                        job['description'],
                        job['jobID'],
                      );
                    }).toList(),
                  ),
                ),
          const SizedBox(height: 24),
          _buildSectionHeader("My Applications"),
          applicationList.isEmpty
              ? const Text("No applications found.")
              : Column(
                  children: applicationList.map((application) {
                    return _buildApplicationRow(
                      application['jobTitle'],
                      application['status'],
                      application['description'],
                      application['department'],
                      application['requiredSkills'],
                      application['experienceYears'],
                      application['education'],
                    );
                  }).toList(),
                ),
          const SizedBox(height: 24),
          _buildSectionHeader("My Jobs Interviews"),
          _buildInterviewRow(
              "Software Engineer", "October 25, 2024", "10:00 PM"),
        ],
      ),
    );
  }

  Widget _buildJobCard(
    BuildContext context,
    String title,
    String department,
    String requiredSkills,
    int experienceYears,
    String education,
    String description,
    int jobID,
  ) {
    return Container(
      width: 200, // Fixed width for cards
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade100, Colors.purple.shade300],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis, // Prevent text overflow
          ),
          const SizedBox(height: 4),
          Text(
            department,
            style: const TextStyle(fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            "Experience: $experienceYears years",
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  _showJobDetailsDialog(
                    context,
                    title,
                    department,
                    description,
                    requiredSkills,
                    experienceYears,
                    education,
                  );
                },
                child: const Text(
                  "View details",
                  style: TextStyle(fontSize: 12),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UploadCVPage(jobID: jobID),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
                child: const Text(
                  "Apply",
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildApplicationRow(
    String title,
    String status,
    String description,
    String department,
    String requiredSkills,
    int experienceYears,
    String education,
  ) {
    return ListTile(
      leading: const CircleAvatar(
        backgroundColor: Colors.purple,
        child: Icon(Icons.work, color: Colors.white),
      ),
      title: Text(title),
      subtitle: Text("Status: $status"),
      trailing: Text(
        status,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
      onTap: () {
        _showJobDetailsDialog(
          context,
          title,
          department,
          description,
          requiredSkills,
          experienceYears,
          education,
        );
      },
    );
  }

  void _showJobDetailsDialog(
    BuildContext context,
    String title,
    String department,
    String description,
    String requiredSkills,
    int experienceYears,
    String education,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Department: $department"),
              const SizedBox(height: 8),
              Text("Description: $description"),
              const SizedBox(height: 8),
              Text("Required Skills: $requiredSkills"),
              const SizedBox(height: 8),
              Text("Experience: $experienceYears years"),
              const SizedBox(height: 8),
              Text("Education: $education"),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        TextButton(onPressed: () {}, child: const Text("See all")),
      ],
    );
  }

  Widget _buildInterviewRow(String jobTitle, String date, String time) {
    return ListTile(
      leading: const CircleAvatar(
        backgroundColor: Colors.purple,
        child: Icon(Icons.calendar_today, color: Colors.white),
      ),
      title: Text(jobTitle),
      subtitle: Text("Interview Date: $date\nInterview Time: $time"),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(onPressed: () {}, child: const Text("View details")),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
            child: const Text("Start"),
          ),
        ],
      ),
    );
  }
}
