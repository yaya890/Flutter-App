import 'package:flutter/material.dart';
import 'uploadCV.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'jobs_interview_page.dart';
import 'available_jobs.dart';

class CandidateHomeScreen extends StatefulWidget {
  const CandidateHomeScreen({super.key, required this.userData});

  final Map<String, dynamic> userData; // Accept userData as a parameter

  @override
  _CandidateHomeScreenState createState() => _CandidateHomeScreenState();
}

class _CandidateHomeScreenState extends State<CandidateHomeScreen> {
  List<dynamic> applicationList = [];
  List<dynamic> jobList = [];
  List<dynamic> interviewList = [];
  Map<String, dynamic> updatedUserData = {}; // To hold updated user data
  bool isLoadingJobs = false;
  bool isLoadingApplications = false;
  bool isLoadingInterviews = false;

  @override
  void initState() {
    super.initState();
    fetchUserID(); // Fetch userID when screen is opened
    fetchJobs();
    fetchApplications();
    fetchInterviews();
  }

  Future<void> fetchUserID() async {
    final email = widget.userData['email']; // Must exist
    final url = Uri.parse('http://127.0.0.1:39542/get_user_id');

    try {
      final response = await http.post(
        url,
        body: json.encode({"email": email}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final userId = json.decode(response.body)['userID']; // Get userID
        setState(() {
          updatedUserData = {
            ...widget.userData,
            'userID': userId,
          };
        });
      } else {
        throw Exception('Failed to fetch user ID');
      }
    } catch (e) {
      print('Error fetching user ID: $e');
    }
  }

  Future<void> fetchJobs() async {
    setState(() {
      isLoadingJobs = true;
    });

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
    } finally {
      setState(() {
        isLoadingJobs = false;
      });
    }
  }

  Future<void> fetchApplications() async {
    setState(() {
      isLoadingApplications = true;
    });

    final url = Uri.parse('http://127.0.0.1:39542/get_my_applications');
    try {
      final response = await http.post(
        url,
        body: json.encode({"userData": widget.userData}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> results = json.decode(response.body);
        setState(() {
          applicationList = results;
        });
      } else {
        final errorResponse = json.decode(response.body);
        print('Error: ${errorResponse['error']}');
      }
    } catch (e) {
      print('Error fetching applications: $e');
    } finally {
      setState(() {
        isLoadingApplications = false;
      });
    }
  }

  Future<void> fetchInterviews() async {
    setState(() {
      isLoadingInterviews = true;
    });

    final url = Uri.parse('http://127.0.0.1:39542/get_my_interviews');
    try {
      final response = await http.post(
        url,
        body: json.encode({"userData": widget.userData}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> results = json.decode(response.body);
        setState(() {
          interviewList = results;
        });
      } else {
        final errorResponse = json.decode(response.body);
        print('Error: ${errorResponse['error']}');
      }
    } catch (e) {
      print('Error fetching interviews: $e');
    } finally {
      setState(() {
        isLoadingInterviews = false;
      });
    }
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
            'Job Title: $title',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4A148C),
            ),
          ),
          Text(
            'Department: $department',
            style: const TextStyle(color: Colors.black54),
          ),
          const Spacer(),
          const SizedBox(height: 10),
          // Removed the "View" and "Apply" buttons
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
            'Job Title: $title',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text('Department: $department'),
          Text('Status: $status'),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
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
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7A1EA1),
              ),
              child: const Text(
                'View Details',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInterviewRow(String jobTitle, String date, String time) {
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
            'Job Title: $jobTitle',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text('Interview Date: $date'),
          Text('Interview Time: $time'),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () {
                // Handle interview start
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7A1EA1),
              ),
              child: const Text(
                'Start Interview',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
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
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  void _logout() {
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
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
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            onPressed: _logout,
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
              leading: const Icon(Icons.home, color: Color(0xFF4A148C)),
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.work, color: Color(0xFF4A148C)),
              title: const Text('Available Jobs'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AvailableJobs(
                      userData: updatedUserData.isEmpty
                          ? widget.userData
                          : updatedUserData,
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.mail_outline, color: Color(0xFF4A148C)),
              title: const Text('Interviews Invitations'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => JobsInterviewPage(
                      userData: updatedUserData.isNotEmpty
                          ? updatedUserData
                          : widget.userData,
                    ),
                  ),
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
                        'Name: ${updatedUserData['name'] ?? widget.userData['name']}',
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

              // Job Listings Section
              _buildSectionHeader('Job Listings'),
              const SizedBox(height: 10),
              isLoadingJobs
                  ? const Center(child: CircularProgressIndicator())
                  : jobList.isEmpty
                      ? const Center(child: Text("No jobs found."))
                      : SizedBox(
                          height: 200,
                          child: Scrollbar(
                            thumbVisibility: true,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: jobList.length,
                              itemBuilder: (context, index) {
                                final job = jobList[index];
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
                              },
                            ),
                          ),
                        ),

              const SizedBox(height: 20),

              // My Applications Section
              _buildSectionHeader('My Applications'),
              const SizedBox(height: 10),
              isLoadingApplications
                  ? const Center(child: CircularProgressIndicator())
                  : applicationList.isEmpty
                      ? const Center(child: Text("No applications found."))
                      : Column(
                          children: applicationList.map((application) {
                            return _buildApplicationRow(
                              application['title'],
                              application['status'],
                              application['description'],
                              application['department'],
                              application['required_skills'],
                              application['experience_years'],
                              application['education'],
                            );
                          }).toList(),
                        ),

              const SizedBox(height: 20),

              // My Interviews Section
              _buildSectionHeader('My Interviews'),
              const SizedBox(height: 10),
              isLoadingInterviews
                  ? const Center(child: CircularProgressIndicator())
                  : interviewList.isEmpty
                      ? const Center(child: Text("No interviews found."))
                      : Column(
                          children: interviewList.map((interview) {
                            return _buildInterviewRow(
                              interview['jobTitle'],
                              interview['date'],
                              interview['time'],
                            );
                          }).toList(),
                        ),
            ],
          ),
        ),
      ),
    );
  }
}
