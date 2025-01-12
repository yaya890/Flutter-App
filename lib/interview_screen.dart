import 'package:flutter/material.dart';

class InterviewScreen extends StatelessWidget {
  const InterviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // الخلفية بلون متدرج
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color.fromARGB(255, 76, 28, 85), Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // المحتوى الرئيسي
          Column(
            children: [
              const SizedBox(height: 50),
              // العنوان في المنتصف
              const Center(
                child: Text(
                  "Interview Chatbot",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 255, 255, 255),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // ترحيب بسيط في البداية
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "Welcome to the Interview Chatbot! 🚀\nLet's start your interview journey.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Color.fromARGB(255, 173, 169, 179)),
                ),
              ),
              Expanded(
                child: ChatBubble(),
              ),
              // شريط الكتابة
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                color: Colors.white,
                child: Row(
                  children: [
                    // أيقونة الملفات
                    IconButton(
                      icon: const Icon(Icons.attach_file, color: Colors.deepPurple),
                      onPressed: () {},
                    ),
                    // حقل إدخال النص
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: "Type your message...",
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    // أيقونة الإرسال
                    IconButton(
                      icon: const Icon(Icons.send, color: Colors.deepPurple),
                      onPressed: () {},
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

class ChatBubble extends StatelessWidget {
  final List<Map<String, String>> messages = [
    {
      'user': '👤',
      'message': "Hello, I'm John Doe. I am a Software Engineer...",
    },
    {
      'bot': '🤖',
      'message': "Hello, John! Let's get started with a few questions.",
    },
    {
      'user': '👤',
      'message': "Thank you, I'm ready!",
    },
    {
      'bot': '🤖',
      'message': "Can you explain the concept of Object-Oriented Programming (OOP)?",
    },
    {
      'user': '👤',
      'message': "OOP is a programming paradigm...",
    },
    {
      'bot': '🤖',
      'message': "Great! How would you handle exceptions in PHP?",
    },
  ];

  ChatBubble({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final isUser = messages[index].containsKey('user');
        return Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isUser ? Colors.deepPurple.shade100 : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 5,
                  offset: const Offset(2, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // الأيقونة على اليسار
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Text(
                    isUser ? messages[index]['user']! : messages[index]['bot']!,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
                // النص داخل الفقاعة
                Flexible(
                  child: Text(
                    isUser
                        ? messages[index]['message']!
                        : messages[index]['message']!,
                    textAlign: TextAlign.left,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

