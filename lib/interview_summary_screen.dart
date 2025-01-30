// interview_summary_screen.dart
import 'package:flutter/material.dart';

class InterviewSummaryScreen extends StatelessWidget {
  final String candidateName;
  final String interviewTitle;
  final String summary;

  const InterviewSummaryScreen({
    super.key,
    required this.candidateName,
    required this.interviewTitle,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$interviewTitle Summary'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display Candidate Name
              Text(
                candidateName,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // Display Interview Title
              Text(
                interviewTitle,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color.fromARGB(255, 255, 255, 255),
                ),
              ),
              const SizedBox(height: 20),

              // Display Summary
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    summary,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Buttons Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Reject Button
                  ElevatedButton(
                    onPressed: () {
                      // Add Reject logic here
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                    ),
                    child: const Text(
                      'Reject',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white, // Change text color to white
                      ),
                    ),
                  ),

                  // Schedule 2nd Interview Button
                  ElevatedButton(
                    onPressed: () {
                      // Add Schedule 2nd Interview logic here
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                    ),
                    child: const Text(
                      'Schedule 2nd Interview',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white, // Change text color to white
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
