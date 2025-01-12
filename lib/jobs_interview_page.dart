import 'package:flutter/material.dart';
import 'interview_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class JobsInterviewPage extends StatefulWidget {
  final String candidateID;

  const JobsInterviewPage({required this.candidateID, super.key});

  @override
  State<JobsInterviewPage> createState() => _JobsInterviewPageState();
}

class _JobsInterviewPageState extends State<JobsInterviewPage> {
  List<Map<String, String>> invitations = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchInvitations();
  }

  Future<void> fetchInvitations() async {
    final url = Uri.parse(
        'http://127.0.0.1:39542/get_invitations?candidateID=${widget.candidateID}');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Log the response for debugging
        print('Response Data: $data');

        if (data['invitations'] != null && data['invitations'] is List) {
          setState(() {
            invitations = List<Map<String, String>>.from(
              data['invitations'].map(
                (invitation) => {
                  "invitationID": invitation["invitationID"]?.toString() ?? "",
                  "title": invitation["title"]?.toString() ?? "No Title",
                  "start": invitation["start"]?.toString() ?? "Unknown Start",
                  "end": invitation["end"]?.toString() ?? "Unknown End",
                  "comment": invitation["comment"]?.toString() ?? "No Comments",
                },
              ),
            );
            isLoading = false;
            errorMessage = '';
          });
        } else {
          throw Exception('Invalid data format for invitations');
        }
      } else {
        throw Exception(
            'Failed to load invitations. HTTP status: ${response.statusCode}');
      }
    } catch (error) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error fetching invitations: $error';
      });
      print('Error fetching invitations: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Jobs Interviews',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 52, 21, 106),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Decorative Circles
          Positioned(
            top: -50,
            left: -50,
            child: _decorativeCircle(150, Colors.deepPurple.withOpacity(0.2)),
          ),
          Positioned(
            bottom: -50,
            right: -50,
            child: _decorativeCircle(150, Colors.purple.withOpacity(0.2)),
          ),

          // Content
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : errorMessage.isNotEmpty
                  ? Center(
                      child: Text(errorMessage,
                          style: const TextStyle(color: Colors.red)))
                  : invitations.isEmpty
                      ? const Center(child: Text('No invitations found'))
                      : ListView.builder(
                          itemCount: invitations.length,
                          itemBuilder: (context, index) {
                            final invitation = invitations[index];
                            print(
                                'Rendering invitation: $invitation'); // Debug log
                            return JobInterviewCard(
                              candidateID: widget.candidateID,
                              invitationID: invitation['invitationID']!,
                              title: invitation['title']!,
                              date: invitation['start']!.split(' ')[0],
                              time: invitation['start']!.split(' ')[1],
                              deadline: invitation['end']!,
                              note: invitation['comment']!,
                            );
                          },
                        ),
        ],
      ),
    );
  }

  Widget _decorativeCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

class JobInterviewCard extends StatelessWidget {
  final String candidateID;
  final String invitationID;
  final String title;
  final String date;
  final String time;
  final String deadline;
  final String note;

  const JobInterviewCard({
    super.key,
    required this.candidateID,
    required this.invitationID,
    required this.title,
    required this.date,
    required this.time,
    required this.deadline,
    required this.note,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                const Icon(Icons.mail_outline, color: Colors.deepPurple),
              ],
            ),
            const SizedBox(height: 10),
            Text('📅 Interview Date: $date'),
            Text('⏰ Interview Time: $time'),
            Text('⏳ Deadline: $deadline'),
            const SizedBox(height: 10),
            Text(
              '📝 $note',
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'View details',
                    style: TextStyle(color: Colors.deepPurple),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => InterviewScreen(
                          candidateID: candidateID,
                          invitationID: invitationID,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Start',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class InterviewScreen extends StatelessWidget {
  final String candidateID;
  final String invitationID;

  const InterviewScreen(
      {super.key, required this.candidateID, required this.invitationID});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Interview Screen'),
      ),
      body: Center(
        child: Text(
          'Candidate ID: $candidateID\nInvitation ID: $invitationID',
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
