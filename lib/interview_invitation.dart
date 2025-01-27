// interview_invitation.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'newInvitation.dart';

// Model Class for Invitation Data
class InterviewInvitation {
  final String title;
  final DateTime start;
  final DateTime end;
  final String comment;
  final int jobID;
  final int invitationID; // Add invitationID here

  InterviewInvitation({
    required this.title,
    required this.start,
    required this.end,
    required this.comment,
    required this.jobID,
    required this.invitationID, // Initialize invitationID
  });

  factory InterviewInvitation.fromJson(Map<String, dynamic> json) {
    return InterviewInvitation(
      title: json['title'],
      start: DateTime.parse(json['start']),
      end: DateTime.parse(json['end']),
      comment: json['comment'],
      jobID: json['jobID'],
      invitationID: json['invitation_id'], // Adjusted to match JSON key
    );
  }
}

// Model Class for Candidate Data
class Candidate {
  final int candidateID;
  final String name;
  final String lastScore; // Store as String to handle multiple types
  final String lastRanking; // Store as String to handle multiple types

  Candidate({
    required this.candidateID,
    required this.name,
    required this.lastScore,
    required this.lastRanking,
  });

  factory Candidate.fromJson(Map<String, dynamic> json) {
    return Candidate(
      candidateID: json['candidateID'],
      name: json['name'],
      lastScore: json['last_score'].toString(), // Convert to String
      lastRanking: json['last_ranking'].toString(), // Convert to String
    );
  }
}

// Fetch Invitations from API
Future<List<InterviewInvitation>> fetchInvitations() async {
  final response =
      await http.get(Uri.parse('http://127.0.0.1:39542/interview_invitations'));

  if (response.statusCode == 200) {
    List<dynamic> data = jsonDecode(response.body);
    return data
        .map((json) => InterviewInvitation.fromJson(json))
        .toList(); // Correctly mapping JSON to model
  } else {
    throw Exception('Failed to load invitations');
  }
}

// Fetch Top Candidates
Future<List<Candidate>> fetchTopCandidates(int jobID) async {
  final response = await http
      .get(Uri.parse('http://127.0.0.1:39542/get_top_candidates?jobID=$jobID'));

  if (response.statusCode == 200) {
    List<dynamic> data = jsonDecode(response.body);
    data.removeWhere((item) => item.containsKey('jobID')); // Remove jobID
    return data.map((json) => Candidate.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load top candidates');
  }
}

// Send Invitation
Future<void> sendInvitation(
    int jobID, int invitationID, List<int> candidateIDs) async {
  final response = await http.post(
    Uri.parse('http://127.0.0.1:39542/send_invite'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'jobID': jobID,
      'invitationID': invitationID,
      'candidateIDs': candidateIDs,
    }),
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to send invitation');
  }
}

// Main Page
class InterviewInvitationPage extends StatelessWidget {
  const InterviewInvitationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text(
          'Interview Invitation',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
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
              child: FutureBuilder<List<InterviewInvitation>>(
                future: fetchInvitations(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No invitations found.'));
                  } else {
                    final invitations = snapshot.data!;
                    return ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: invitations.length,
                      itemBuilder: (context, index) {
                        final invitation = invitations[index];
                        return Column(
                          children: [
                            InterviewCard(
                              role: invitation.title,
                              name: "N/A",
                              start:
                                  "${invitation.start.toLocal().toString().split(' ')[0]} ${invitation.start.toLocal().toString().split(' ')[1]}",
                              end:
                                  "${invitation.end.toLocal().toString().split(' ')[0]} ${invitation.end.toLocal().toString().split(' ')[1]}",
                              comments: invitation.comment,
                              jobID: invitation.jobID,
                              invitationID: invitation
                                  .invitationID, // Pass invitationID here
                            ),
                            const SizedBox(height: 20),
                          ],
                        );
                      },
                    );
                  }
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
                          builder: (context) => const NewInvitation()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor:
                        Colors.deepPurple, // Button background color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.add_circle_outline,
                      color: Colors.white, size: 24),
                  label: const Text(
                    'New Invitation',
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
}

// Card Widget for Each Invitation
class InterviewCard extends StatelessWidget {
  final String role;
  final String name;
  final String start;
  final String end;
  final String comments;
  final int jobID;
  final int invitationID; // Add invitationID here

  const InterviewCard({
    super.key,
    required this.role,
    required this.name,
    required this.start,
    required this.end,
    required this.comments,
    required this.jobID,
    required this.invitationID, // Initialize invitationID
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.purple, Colors.orangeAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(4, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.work, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  role,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.calendar_today, color: Colors.white70, size: 18),
              const SizedBox(width: 8),
              Text(
                "Start: $start",
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.timer, color: Colors.white70, size: 18),
              const SizedBox(width: 8),
              Text(
                "End: $end",
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            "Comments:",
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            comments,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white70,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.deepPurple,
                ),
                onPressed: () async {
                  final candidates = await fetchTopCandidates(jobID);
                  showDialog(
                    context: context,
                    builder: (_) => CandidateSelectionDialog(
                      candidates: candidates,
                      jobID: jobID,
                      invitationID: invitationID, // Pass invitationID here
                    ),
                  );
                },
                icon: const Icon(Icons.send, size: 16),
                label: const Text(
                  'Send to...',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Candidate Selection Dialog
class CandidateSelectionDialog extends StatefulWidget {
  final List<Candidate> candidates;
  final int jobID;
  final int invitationID;

  const CandidateSelectionDialog({
    super.key,
    required this.candidates,
    required this.jobID,
    required this.invitationID,
  });

  @override
  _CandidateSelectionDialogState createState() =>
      _CandidateSelectionDialogState();
}

class _CandidateSelectionDialogState extends State<CandidateSelectionDialog> {
  List<int> selectedCandidateIDs = [];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Candidates'),
      content: SizedBox(
        height: 300,
        width: 300,
        child: ListView.builder(
          itemCount: widget.candidates.length,
          itemBuilder: (context, index) {
            final candidate = widget.candidates[index];
            return CheckboxListTile(
              title: Text(candidate.name),
              subtitle: Text(
                  'Rank: ${candidate.lastRanking}, Score: ${candidate.lastScore}'),
              value: selectedCandidateIDs.contains(candidate.candidateID),
              onChanged: (bool? selected) {
                setState(() {
                  if (selected == true) {
                    selectedCandidateIDs.add(candidate.candidateID);
                  } else {
                    selectedCandidateIDs.remove(candidate.candidateID);
                  }
                });
              },
            );
          },
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () async {
            await sendInvitation(
                widget.jobID, widget.invitationID, selectedCandidateIDs);
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Invitation sent successfully!'),
              ),
            );
          },
          child: const Text('Send Invitation'),
        ),
      ],
    );
  }
}
