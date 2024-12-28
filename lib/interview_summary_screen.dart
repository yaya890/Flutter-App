import 'package:flutter/material.dart';

class InterviewSummaryScreen extends StatelessWidget {
  final String candidateName;
  final String interviewTitle;

  const InterviewSummaryScreen({
    Key? key,
    required this.candidateName,
    required this.interviewTitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$interviewTitle Summary'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Candidate: $candidateName',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Summary details go here...',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}