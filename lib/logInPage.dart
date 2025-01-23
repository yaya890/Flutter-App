// logInPage.dart
import 'package:flutter/material.dart';
import 'dart:convert'; // For JSON encoding/decoding
import 'package:http/http.dart' as http; // For making HTTP requests
import 'HRhomeScreen.dart';
import 'candidate_home_screen.dart';
import 'welcomePage.dart';
import 'signUpPage.dart'; // Import the signup page
import 'forgotPassword.dart'; // Import the forgot password page

class LogInPage extends StatefulWidget {
  final String role;

  const LogInPage({super.key, required this.role});

  @override
  State<LogInPage> createState() => _LogInPageState();
}

class _LogInPageState extends State<LogInPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false; // For showing a loading spinner

  // Base URL of the backend API
  final String _baseUrl = 'http://127.0.0.1:39542';

  // Function to handle login
  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showErrorDialog('Please fill in both email and password.');
      return;
    }

    setState(() {
      _isLoading = true; // Show loading spinner
    });

    try {
      // Send HTTP POST request to the /login endpoint
      final response = await http.post(
        Uri.parse('$_baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'role': widget.role,
        }),
      );

      // Handle response
      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);

        // Navigate based on role
        if (widget.role.toLowerCase() == 'hrmanager') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HRhomeScreen(userData: userData),
            ),
          );
        } else if (widget.role.toLowerCase() == 'candidate') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CandidateHomeScreen(userData: userData),
            ),
          );
        } else {
          _showErrorDialog('Unknown role. Please contact support.');
        }
      } else {
        final errorResponse = jsonDecode(response.body);
        _showErrorDialog(errorResponse['error'] ?? 'Invalid credentials.');
      }
    } catch (e) {
      _showErrorDialog('An error occurred: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false; // Hide loading spinner
      });
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
                                    onPressed: _isLoading ? null : _login,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      elevation: 0,
                                    ),
                                    child: _isLoading
                                        ? const CircularProgressIndicator(
                                            color: Colors.white,
                                          )
                                        : const Text(
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

                                // Links: Signup and Forgot Password
                                Center(
                                  child: Column(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  SignUpPage(role: widget.role),
                                            ),
                                          );
                                        },
                                        child: const Text(
                                          'Don’t have an account? Sign up',
                                          style: TextStyle(
                                            color: Colors.blue,
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  ForgotPasswordPage(),
                                            ),
                                          );
                                        },
                                        child: const Text(
                                          'Forgot your password?',
                                          style: TextStyle(
                                            color: Colors.blue,
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
