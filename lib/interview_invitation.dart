import 'package:flutter/material.dart';

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
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: const [
                  InterviewCard(
                    role: "Software Engineer",
                    name: "John Doe",
                    interviewDate: "October 20, 2024",
                    interviewTime: "2:00 PM (EST)",
                    deadline: "October 18, 2024",
                    comments:
                        "Please prepare for technical questions related to programming languages, algorithms, and software development methodologies. Be ready to discuss your previous projects and experiences.",
                  ),
                  SizedBox(height: 20),
                  InterviewCard(
                    role: "Marketing Specialist",
                    name: "Sophia Davis",
                    interviewDate: "October 22, 2024",
                    interviewTime: "10:00 AM (EST)",
                    deadline: "October 20, 2024",
                    comments:
                        "Be ready to discuss your previous projects and experiences.",
                  ),
                  SizedBox(height: 20),
                  InterviewCard(
                    role: "Product Manager",
                    name: "Ethan Miller",
                    interviewDate: "October 25, 2024",
                    interviewTime: "1:00 PM (EST)",
                    deadline: "October 23, 2024",
                    comments:
                        "Please reflect on your approach to product vision and strategy during the interview.",
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Add action for "+ New Invitation"
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.deepPurple, // Button background color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.add_circle_outline, color: Colors.white, size: 24),
                  label: const Text(
                    '+ New Invitation',
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

class InterviewCard extends StatelessWidget {
  final String role;
  final String name;
  final String interviewDate;
  final String interviewTime;
  final String deadline;
  final String comments;

  const InterviewCard({
    super.key,
    required this.role,
    required this.name,
    required this.interviewDate,
    required this.interviewTime,
    required this.deadline,
    required this.comments,
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
              const Icon(Icons.person, color: Colors.white70, size: 18),
              const SizedBox(width: 8),
              Text(
                name,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
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
                "Date: $interviewDate, Time: $interviewTime",
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
                "Deadline: $deadline",
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
                onPressed: () {},
                icon: const Icon(Icons.send, size: 16),
                label: const Text(
                  'Send',
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
