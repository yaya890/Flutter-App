import 'package:flutter/material.dart';
import 'availableJobs.dart'; // Import AvailableJobs page
import 'jobsInterviews.dart'; // Import JobsInterviews page
import 'applicationsTracking.dart'; // Import ApplicationsTracking page

class CandidateHomeScreen extends StatelessWidget {
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
            icon: const Icon(Icons.person, color: Colors.black),
            onPressed: () {
              // Profile functionality placeholder
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            onPressed: () {
              // Log-out functionality placeholder
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 125, 25, 155),
              ),
              child: const Center(
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
              title: const Text('Available Jobs'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AvailableJobs()),
                );
              },
            ),
           /* ListTile(
              leading: const Icon(Icons.interpreter_mode, color: Color(0xFF4A148C)),
              title: const Text('Job Interviews'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const JobsInterviews()),
                );
              },
            ),*/
            /* ListTile(
              leading: const Icon(Icons.track_changes, color: Color(0xFF4A148C)),
              title: const Text('Applications Tracking'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ApplicationsTracking()),
                );
              },
            ), */ 
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Job Listings Section
            const Text(
              "Jobs Listings\nRecommended for you",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 180,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: const [
                  JobCard(
                    title: "VR Designer",
                    company: "Meta",
                    location: "London, UK (Remote)",
                    daysAgo: "5 days ago",
                  ),
                  JobCard(
                    title: "Product Manager",
                    company: "Meta",
                    location: "Riyadh, KSA",
                    daysAgo: "1 day ago",
                  ),
                  JobCard(
                    title: "UI Designer",
                    company: "Meta",
                    location: "Mecca, KSA",
                    daysAgo: "3 days ago",
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // My Applications Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "My Applications",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text("See all"),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const ApplicationRow(
              title: "VR Designer",
              onDetailsTap: () {},
              onStatusTap: () {},
            ),
            const ApplicationRow(
              title: "Product Manager",
              onDetailsTap: () {},
              onStatusTap: () {},
            ),
            const SizedBox(height: 24),
            // My Jobs Interviews Section
            const Text(
              "My Job Interviews",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const InterviewRow(
              title: "Software Engineer",
              date: "October 25, 2024",
              time: "10:00 PM",
              onDetailsTap: () {},
              onStartTap: () {},
            ),
            const SizedBox(height: 24),
            // My Performance Section
            const Text(
              "My Performance",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                PerformanceCard(
                  icon: Icons.pie_chart,
                  onTap: () {},
                ),
                PerformanceCard(
                  icon: Icons.bar_chart,
                  onTap: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class JobCard extends StatelessWidget {
  final String title;
  final String company;
  final String location;
  final String daysAgo;

  const JobCard({
    required this.title,
    required this.company,
    required this.location,
    required this.daysAgo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 16),
      width: 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [Colors.purple.shade100, Colors.purple.shade200],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(company),
            const SizedBox(height: 4),
            Text(location),
            const Spacer(),
            Text(daysAgo, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  child: const Text("View details"),
                ),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text("Apply"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ApplicationRow extends StatelessWidget {
  final String title;
  final VoidCallback onDetailsTap;
  final VoidCallback onStatusTap;

  const ApplicationRow({
    required this.title,
    required this.onDetailsTap,
    required this.onStatusTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      trailing: Wrap(
        spacing: 8,
        children: [
          TextButton(onPressed: onDetailsTap, child: const Text("View details")),
          TextButton(onPressed: onStatusTap, child: const Text("Status")),
        ],
      ),
    );
  }
}

class InterviewRow extends StatelessWidget {
  final String title;
  final String date;
  final String time;
  final VoidCallback onDetailsTap;
  final VoidCallback onStartTap;

  const InterviewRow({
    required this.title,
    required this.date,
    required this.time,
    required this.onDetailsTap,
    required this.onStartTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: Text("Interview Date: $date\nInterview Time: $time"),
      trailing: Wrap(
        spacing: 8,
        children: [
          TextButton(onPressed: onDetailsTap, child: const Text("View details")),
          TextButton(onPressed: onStartTap, child: const Text("Start")),
        ],
      ),
    );
  }
}

class PerformanceCard extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const PerformanceCard({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.purple.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 60, color: Colors.purple),
      ),
    );
  }
}
