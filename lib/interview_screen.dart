import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class InterviewScreen extends StatefulWidget {
  final String candidateID;
  final String invitationID;

  const InterviewScreen(
      {super.key, required this.candidateID, required this.invitationID});

  @override
  State<InterviewScreen> createState() => _InterviewScreenState();
}

class _InterviewScreenState extends State<InterviewScreen> {
  final List<Map<String, String>> messages = [];
  final TextEditingController _messageController = TextEditingController();
  bool isChatEnding = false;
  Map<String, dynamic>? jobDetails; // Holds job details from the backend

  @override
  void initState() {
    super.initState();
    _startChat();
  }

  Future<void> _startChat() async {
    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:39542/start_interview'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"invitationID": widget.invitationID}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          jobDetails = data['job_details']; // Store job details for later use
          messages.add({"bot": data["bot_message"]});
        });
      } else {
        setState(() {
          messages.add({"bot": "Error: Unable to start the interview."});
        });
      }
    } catch (e) {
      setState(() {
        messages.add({"bot": "Error: Failed to connect to the server."});
      });
    }
  }

  Future<void> _sendMessage(String userMessage) async {
    setState(() {
      messages.add({"user": userMessage});
    });

    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:39542/send_message'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "invitationID": widget.invitationID,
          "jobDetails": jobDetails,
          "message": userMessage,
          "chat_history": messages.map((m) {
            return {
              "role": m.containsKey('user') ? "user" : "assistant",
              "content": m.values.first,
            };
          }).toList(),
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          messages.add({"bot": data["bot_message"]});
        });

        if (data["is_chat_ending"] == true) {
          setState(() {
            isChatEnding = true;
          });

          // Redirect to previous page after a delay
          Future.delayed(const Duration(seconds: 2), () {
            Navigator.pop(context);
          });
        }
      }
    } catch (e) {
      setState(() {
        messages.add({"bot": "Error: Failed to connect to the server."});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color.fromARGB(255, 76, 28, 85), Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Column(
            children: [
              const SizedBox(height: 50),
              const Center(
                child: Text(
                  "Interview Chatbot",
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final isUser = messages[index].containsKey('user');
                    return Align(
                      alignment:
                          isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isUser
                              ? Colors.deepPurple.shade100
                              : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          messages[index][isUser ? 'user' : 'bot']!,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        enabled: !isChatEnding,
                        decoration: InputDecoration(
                          hintText: isChatEnding
                              ? "The interview has ended."
                              : "Type your message...",
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send, color: Colors.deepPurple),
                      onPressed: isChatEnding
                          ? null
                          : () {
                              final userMessage =
                                  _messageController.text.trim();
                              if (userMessage.isNotEmpty) {
                                _messageController.clear();
                                _sendMessage(userMessage);
                              }
                            },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
