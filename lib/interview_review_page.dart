import 'package:flutter/material.dart';
import 'interview_summary_screen.dart';
import 'interview_invitation.dart';

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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple, Colors.purpleAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  'Interviews Review',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => InterviewInvitationPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.mail_outline,
                      color: Colors.white, size: 24),
                  label: const Text(
                    'View Invitations',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInterviewCard(
      Map<String, String> interview, BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildIcon(),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  interview['title']!,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Candidate Name: ${interview['candidate']}',
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
                Text(
                  'Interview Status: ${interview['status']}',
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
                Text(
                  'Interview Outcome: ${interview['outcome']}',
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
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
              backgroundColor: Colors.deepPurple,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              interview['action']!,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      padding: const EdgeInsets.all(10),
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
