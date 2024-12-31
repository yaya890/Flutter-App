import 'package:flutter/material.dart';
import 'interview_summary_screen.dart'; // Import the summary screen

class InterviewReviewPage extends StatelessWidget {
  final List<Map<String, String>> interviews = [
    {
      'title': 'Software Engineer',
      'candidate': 'Jack Williamson',
      'status': 'Completed',
      'outcome': 'Pass',
      'action': 'View Summary',
    },
    {
      'title': 'Marketing Specialist',
      'candidate': 'Sophia Davis',
      'status': 'Pending',
      'outcome': '-',
      'action': 'Scheduled',
    },
    {
      'title': 'Data Analyst',
      'candidate': 'Emma Williams',
      'status': 'Not Completed',
      'outcome': '-',
      'action': 'Rescheduled',
    },
    {
      'title': 'Product Manager',
      'candidate': 'Ethan Miller',
      'status': 'Completed',
      'outcome': 'Fail',
      'action': 'View Summary',
    },
  ];

  InterviewReviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 120, 59, 129),
      body: Stack(
        children: [
          _buildDecorativeCircles(),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    'Interviews Review',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(255, 255, 255, 255),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: interviews.length,
                    itemBuilder: (context, index) {
                      final interview = interviews[index];
                      return _buildInterviewCard(interview, context);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDecorativeCircles() {
    return Stack(
      children: [
        Positioned(
          top: -60,
          left: -60,
          child: _buildCircle(180, Color.fromARGB(
            (0.3 * 255).toInt(),
            Colors.purple.shade200.red,
            Colors.purple.shade200.green,
            Colors.purple.shade200.blue,
          )),
        ),
        Positioned(
          bottom: -80,
          right: -80,
          child: _buildCircle(200, Color.fromARGB(
            (0.2 * 255).toInt(),
            Colors.purple.shade300.red,
            Colors.purple.shade300.green,
            Colors.purple.shade300.blue,
          )),
        ),
        Positioned(
          top: 100,
          right: -50,
          child: _buildCircle(150, Color.fromARGB(
            (0.4 * 255).toInt(),
            Colors.purple.shade100.red,
            Colors.purple.shade100.green,
            Colors.purple.shade100.blue,
          )),
        ),
      ],
    );
  }

  Widget _buildCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildInterviewCard(Map<String, String> interview, BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildIcon(),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  interview['title']!,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Candidate Name: ${interview['candidate']}',
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
                Text(
                  'Interview Status: ${interview['status']}',
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
                Text(
                  'Interview Outcome: ${interview['outcome']}',
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: interview['action'] == 'View Summary'
                ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => InterviewSummaryScreen(
                          candidateName: interview['candidate']!,
                          interviewTitle: interview['title']!,
                        ),
                      ),
                    );
                  }
                : null, // Disable for other actions
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(159, 125, 44, 157),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              interview['action']!,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.purple.shade100,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.person,
        color: Colors.purple.shade700,
        size: 30,
      ),
    );
  }
}
