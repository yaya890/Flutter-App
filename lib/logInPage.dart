import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import 'forgotPassword.dart';
import 'signUpPage.dart';
import 'HRhomeScreen.dart'; // Import HR Home Screen
import 'candidate_home_screen.dart'; // Import Candidate Home Screen
import 'welcomePage.dart'; // Import the WelcomePage

class LogInPage extends StatefulWidget {
  final String role; // Role passed from the WelcomePage

  const LogInPage({super.key, required this.role});

  @override
  State<LogInPage> createState() => _LogInPageState();
}

class _LogInPageState extends State<LogInPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Initialize Dio instance
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://127.0.0.1:39542',
    headers: {'Content-Type': 'application/json'},
  ));

  // Function to handle login
  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // Validate fields
    if (email.isEmpty || password.isEmpty) {
      _showErrorDialog('Please fill in both email and password.');
      return;
    }

    try {
      // Send login request with email, password, and role
      final response = await _dio.post(
        '/login',
        data: {
          'email': email,
          'password': password,
          'role': widget.role, // Include the role passed from WelcomePage
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;

        // Check if the user was found and navigate to the appropriate home screen
        if (data['role'].toLowerCase() == 'hr manager') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HRhomeScreen(
                userData: {
                  'userID': data['userID'],
                  'name': data['name'],
                  'email': data['email'],
                  'role': data['role'],
                },
              ),
            ),
          );
        } else if (data['role'].toLowerCase() == 'candidate') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CandidateHomeScreen(
                userData: {
                  'userID': data['userID'],
                  'name': data['name'],
                  'email': data['email'],
                  'role': data['role'],
                },
              ),
            ),
          );
        } else {
          _showErrorDialog('Unknown role. Please contact support.');
        }
      } else {
        // Handle server error
        final error = response.data['error'] ?? 'Login failed';
        _showErrorDialog(error);
      }
    } catch (e) {
      // Handle any exceptions
      debugPrint('An error occurred during login: $e');
      _showErrorDialog('An error occurred. Please try again later.');
    }
  }

  // Function to show error dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF7A1EA1),
                  Color(0xFF4A148C),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Back Arrow
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      onPressed: () {
                        // Navigate back to WelcomePage
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => WelcomePage(),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          // Rounded White Container
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Title: Login
                                const Center(
                                  child: Text(
                                    'Login',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF4A148C),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),

                                // Subtitle
                                const Center(
                                  child: Text(
                                    'Sign in to continue.',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 30),

                                // Email Input Field
                                const Text(
                                  'EMAIL',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black54,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                TextField(
                                  controller: _emailController,
                                  decoration: InputDecoration(
                                    hintText: 'example@example.com',
                                    hintStyle: const TextStyle(
                                      color: Colors.black45,
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey.shade200,
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide.none,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                        color: Color(0xFF4A148C),
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  keyboardType: TextInputType.emailAddress,
                                ),
                                const SizedBox(height: 20),

                                // Password Input Field
                                const Text(
                                  'PASSWORD',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black54,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                TextField(
                                  controller: _passwordController,
                                  obscureText: true,
                                  decoration: InputDecoration(
                                    hintText: '******',
                                    hintStyle: const TextStyle(
                                      color: Colors.black45,
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey.shade200,
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide.none,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                        color: Color(0xFF4A148C),
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 30),

                                // Log in Button
                                Container(
                                  width: double.infinity,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF7A1EA1),
                                        Color(0xFF4A148C),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: ElevatedButton(
                                    onPressed: _login,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      elevation: 0,
                                    ),
                                    child: const Text(
                                      'Log in',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // Forgot Password and Signup Links
                                Center(
                                  child: Column(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const ForgotPasswordPage(),
                                            ),
                                          );
                                        },
                                        child: const Text(
                                          'Forgot Password?',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.black54,
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      GestureDetector(
                                        onTap: () {
                                          // Navigate to SignUpPage
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const SignUpPage(),
                                            ),
                                          );
                                        },
                                        child: const Text(
                                          'Signup!',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.black54,
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
