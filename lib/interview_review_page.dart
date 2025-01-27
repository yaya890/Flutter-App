// interview_review_page.dart
import 'package:flutter/material.dart';
import 'interview_summary_screen.dart';
import 'interview_invitation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class InterviewReviewPage extends StatefulWidget {
  const InterviewReviewPage({super.key});

  @override
  _InterviewReviewPageState createState() => _InterviewReviewPageState();
}

class _InterviewReviewPageState extends State<InterviewReviewPage> {
  List<Map<String, dynamic>> interviews = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchInterviews();
  }

  Future<void> _fetchInterviews() async {
    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:39542/get_all_candidates_invitations'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          interviews = data.map((interview) {
            return {
              'title': interview['job_title'],
              'candidate': interview['candidate_name'],
              'status': interview['status'],
              'application_id': interview['application_id'],
              'invitation_id': interview['invitation_id'],
            };
          }).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  // Function to fetch the summary from the backend
  Future<String> _fetchCandidateSummary(
      int invitationId, int applicationId) async {
    try {
      final response = await http.get(
        Uri.parse(
            'http://127.0.0.1:39542/get_candidate_summary?invitation_id=$invitationId&application_id=$applicationId'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['summary']; // Return the summary
      } else if (response.statusCode == 404) {
        throw Exception('No summary found for the provided IDs');
      } else {
        throw Exception('Failed to load summary');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            // Navigate back to HRHomeScreen
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Interviews Review',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
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
            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.white))
                  : ListView.builder(
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
                        builder: (context) => const InterviewInvitationPage(),
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
      Map<String, dynamic> interview, BuildContext context) {
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
                  interview['title'],
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
              ],
            ),
          ),
          ElevatedButton(
            onPressed: interview['status'] == 'Interview Done'
                ? () async {
                    try {
                      // Fetch the summary from the backend
                      final summary = await _fetchCandidateSummary(
                        interview['invitation_id'],
                        interview['application_id'],
                      );

                      // Navigate to the InterviewSummaryScreen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => InterviewSummaryScreen(
                            candidateName: interview['candidate'],
                            interviewTitle: interview['title'],
                            summary: summary, // Pass the fetched summary
                          ),
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                  }
                : null, // Disable for other statuses
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'View Summary',
              style: TextStyle(color: Colors.white),
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
