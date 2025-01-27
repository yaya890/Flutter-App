// HRhomeScreen.dart
import 'package:flutter/material.dart';
import 'jobPostings.dart'; // Import JobPostings page
import 'interview_review_page.dart'; // Import InterviewReviewPage

class HRhomeScreen extends StatelessWidget {
  final Map<String, dynamic> userData;

  // Constructor to accept user data
  const HRhomeScreen({super.key, required this.userData});

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
        centerTitle: true, // Center the title
        title: const Text(
          'Home',
          style: TextStyle(
            color: Color(0xFF4A148C), // Purple color
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Colors.black),
            onPressed: () {
              // Profile functionality placeholder
              debugPrint("User Data: $userData"); // For debugging purposes
            },
          ),
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
            DrawerHeader(
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 125, 25, 155),
              ),
              child: Center(
                // Centers the text
                child: const Text(
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
                        'Name: ${userData['name']}', // Dynamically display the name
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

              // Active Job Posts Section
              _buildSectionHeader('Active Job Posts', 'See all Posts'),
              const SizedBox(height: 10),
              SizedBox(
                height: 200,
                child: Scrollbar(
                  thumbVisibility: true, // Ensures the scrollbar is visible
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 5, // Placeholder count
                    itemBuilder: (context, index) => _buildJobCard(),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Finished Interviews Section
              _buildSectionHeader('Finished Interviews', 'See all Interviews'),
              const SizedBox(height: 10),
              SizedBox(
                height: 300, // Ensure proper scrolling height
                child: ListView.builder(
                  itemCount: 5, // Placeholder count
                  itemBuilder: (context, index) => _buildInterviewRow(),
                ),
              ),
              const SizedBox(height: 20),

              // KPIs Overview Section
              _buildSectionHeader('KPIs Overview', 'See all KPIs'),
              const SizedBox(height: 10),
              _buildKPISection(),
              const SizedBox(height: 20),

              // Performance Trends Section
              _buildSectionHeader('Performance Trends', 'See all'),
              const SizedBox(height: 10),
              _buildChartPlaceholder(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String action) {
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
        TextButton(
          onPressed: () {
            // Action button functionality placeholder
          },
          child: Text(
            action,
            style: const TextStyle(color: Colors.blue),
          ),
        ),
      ],
    );
  }

  Widget _buildJobCard() {
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
          const Text(
            'Job Title: ', // Placeholder
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4A148C),
            ),
          ),
          const Text('Company: ', style: TextStyle(color: Colors.black54)),
          const Text('Location: ', style: TextStyle(color: Colors.black54)),
          const Spacer(),
          const Text('Days Ago: ', style: TextStyle(color: Colors.black54)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: ElevatedButton(
                  onPressed: null, // Placeholder
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7A1EA1), // Purple button
                  ),
                  child: const Text('View Applications'),
                ),
              ),
              const SizedBox(width: 5),
              Flexible(
                child: ElevatedButton(
                  onPressed: null, // Placeholder
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7A1EA1), // Purple button
                  ),
                  child: const Text('Edit'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInterviewRow() {
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
          const Text('Interview Title: ',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const Text('Candidate Name: '),
          const Text('Interview Status: '),
          const Text('Outcome: '),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: null, // Placeholder
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7A1EA1), // Purple button
              ),
              child: const Text('View Summary'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKPISection() {
    return Column(
      children: [
        _buildKPIProgress('Project Completion Rate', '70%'),
        _buildKPIProgress('Sales Target', '55%'),
      ],
    );
  }

  Widget _buildKPIProgress(String kpi, String progress) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          flex: 2,
          child: Text(kpi, style: const TextStyle(fontSize: 16)),
        ),
        Expanded(
          flex: 4,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: LinearProgressIndicator(
              value: double.parse(progress.replaceAll('%', '')) / 100,
              backgroundColor: Colors.grey.shade300,
              color: Colors.blue,
            ),
          ),
        ),
        Flexible(
          flex: 1,
          child: Text(progress),
        ),
      ],
    );
  }

  Widget _buildChartPlaceholder() {
    return Container(
      height: 200,
      color: Colors.grey.shade200,
      child: const Center(
        child: Text(
          'Chart Placeholder',
          style: TextStyle(color: Colors.black54),
        ),
      ),
    );
  }
}
