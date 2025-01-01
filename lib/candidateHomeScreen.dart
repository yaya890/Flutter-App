import 'package:flutter/material.dart';
import 'availableJobs.dart'; // Import AvailableJobs page

class CandidateHomeScreen extends StatelessWidget {
  const CandidateHomeScreen({super.key});

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
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        centerTitle: true,
        title: const Text(
          'Home',
          style: TextStyle(
            color: Color(0xFF4A148C),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            onPressed: () {},
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
              title: const Text('Available Jobs'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AvailableJobs()),
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
              _buildWelcomeSection(),
              const SizedBox(height: 20),

              _buildSectionHeader('Job Listings', 'See all Jobs'),
              const SizedBox(height: 10),
              SizedBox(
                height: 200,
                child: Scrollbar(
                  thumbVisibility: true,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 5,
                    itemBuilder: (context, index) => _buildJobCard(),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              _buildSectionHeader('My Applications', 'See all Applications'),
              const SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 5,
                itemBuilder: (context, index) => _buildApplicationRow(),
              ),
              const SizedBox(height: 20),

              _buildSectionHeader('My Performance', 'See all KPIs'),
              const SizedBox(height: 10),
              _buildKPISection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Row(
      children: [
        const CircleAvatar(
          radius: 30,
          backgroundColor: Colors.purple,
          child: Icon(Icons.person, color: Colors.white, size: 30),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Hello,',
              style: TextStyle(fontSize: 18, color: Colors.black54),
            ),
            Text(
              'Candidate Name', // Placeholder for candidate name
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4A148C),
              ),
            ),
          ],
        ),
      ],
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
          onPressed: () {},
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
          ElevatedButton(
            onPressed: () {}, // Placeholder
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7A1EA1), // Purple button
            ),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  Widget _buildApplicationRow() {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('Job Title: ', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('Application Status: '),
            ],
          ),
          ElevatedButton(
            onPressed: () {}, // Placeholder
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7A1EA1),
            ),
            child: const Text('View Details'),
          ),
        ],
      ),
    );
  }

  Widget _buildKPISection() {
    return Column(
      children: [
        _buildKPIProgress('Applications Submitted', '80%'),
        _buildKPIProgress('Interviews Completed', '60%'),
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
}
