import 'package:flutter/material.dart';
import 'available_jobs.dart';
import 'uploadCV.dart';
import 'jobs_interview_page.dart'; // Import the JobsInterviewPage.

class CandidateHomeScreen extends StatelessWidget {
  const CandidateHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
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
        title: const Text("Hello, John Doe"),
        backgroundColor: Colors.purple,
        elevation: 0,
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
                Navigator.pop(context); // Close the drawer.
              },
            ),
            ListTile(
              leading: const Icon(Icons.work),
              title: const Text("Available Jobs"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AvailableJobs()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.mail_outline), // Icon for Interviews Invitations
              title: const Text("Interviews Invitations"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => JobsInterviewPage(candidateID: '1'), // Pass candidateID
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text("Logout"),
              onTap: () {
                Navigator.pop(context); // Close the drawer.
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
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildJobCard(context, "VR Designer", "Meta", "London, UK (Remote)", "5 days ago", 1),
                const SizedBox(width: 16),
                _buildJobCard(context, "Product Manager", "Meta", "Riyadh", "1 day ago", 2),
                const SizedBox(width: 16),
                _buildJobCard(context, "UI Designer", "Meta", "Mecca, KSA", "3 days ago", 3),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader("My Applications"),
          _buildApplicationRow("VR Designer"),
          _buildApplicationRow("Product Manager"),
          const SizedBox(height: 24),
          _buildSectionHeader("My Jobs Interviews"),
          _buildInterviewRow("Software Engineer", "October 25, 2024", "10:00 PM"),
          const SizedBox(height: 24),
          _buildSectionHeader("My Performance"),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildPerformanceCard(Icons.pie_chart, "View details"),
              _buildPerformanceCard(Icons.bar_chart, "View details"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildJobCard(BuildContext context, String title, String company, String location, String timeAgo, int jobID) {
    return Container(
      width: 200,
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
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(company),
          const SizedBox(height: 4),
          Text(location),
          const SizedBox(height: 4),
          Text(timeAgo, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(onPressed: () {}, child: const Text("View details")),
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
                child: const Text("Apply"),
              ),
            ],
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

  Widget _buildApplicationRow(String jobTitle) {
    return ListTile(
      leading: const CircleAvatar(
        backgroundColor: Colors.purple,
        child: Icon(Icons.work, color: Colors.white),
      ),
      title: Text(jobTitle),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(onPressed: () {}, child: const Text("View details")),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
            child: const Text("Status"),
          ),
        ],
      ),
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

  Widget _buildPerformanceCard(IconData icon, String label) {
    return Column(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: Colors.purple.shade100,
          child: Icon(icon, color: Colors.purple, size: 30),
        ),
        const SizedBox(height: 8),
        TextButton(onPressed: () {}, child: Text(label)),
      ],
    );
  }
}
