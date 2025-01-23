// verificationPage.dart

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class VerificationPage extends StatefulWidget {
  final String role;
  final String email;
  final Map<String, dynamic> userData; // Includes all user data

  const VerificationPage({
    super.key,
    required this.role,
    required this.email,
    required this.userData,
  });

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  final List<TextEditingController> _otpControllers =
      List.generate(4, (_) => TextEditingController());
  bool _isLoading = false;

  final String _baseUrl = 'http://127.0.0.1:39542'; // Base URL of the API

  // Function to verify the code
  Future<void> _verifyCode() async {
    final code = _otpControllers.map((controller) => controller.text).join();

    if (code.length != 4) {
      _showDialog('Error', 'Please enter the 4-digit code.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/verify'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': widget.email,
          'code': code,
        }),
      );

      if (response.statusCode == 200) {
        _showDialog(
            'Verification Successful', 'Go to login to enter your account.');
        await _storeNewUser(); // Call to store the new user
      } else {
        final errorMessage = jsonDecode(response.body)['error'];
        _showDialog('Error', errorMessage);
      }
    } catch (e) {
      _showDialog('Error', 'An error occurred: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Function to store new user
  Future<void> _storeNewUser() async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/store_new_user'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': widget.userData['name'], // Ensure name is present
          'email': widget.userData['email'], // Ensure email is present
          'password': widget.userData['password'], // Ensure password is present
          'role': widget.role, // Ensure role is included
        }),
      );

      if (response.statusCode == 201) {
        print('User stored successfully');
      } else if (response.statusCode == 400) {
        final errorMessage = jsonDecode(response.body)['error'];
        print('Validation Error: $errorMessage');
      } else {
        final errorMessage = jsonDecode(response.body)['error'];
        print('Error storing user: $errorMessage');
      }
    } catch (e) {
      print('Error: ${e.toString()}');
    }
  }

  // Helper function to show dialogs
  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF7A1EA1), Color(0xFF4A148C)], // Purple gradient
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Back Button
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ),

              // Main Content
              Expanded(
                child: Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.85,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Title
                        const Text(
                          'Account Verification',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4A148C),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Subtitle
                        const Text(
                          'Please Enter the 4 Digit Code\nSent to Your Email',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 30),

                        // OTP Fields
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: _otpControllers.map((controller) {
                            return _otpTextField(controller);
                          }).toList(),
                        ),
                        const SizedBox(height: 30),

                        // Verify Button
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
                          child: TextButton(
                            onPressed: _isLoading ? null : _verifyCode,
                            child: _isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text(
                                    'Verify',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
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
      ),
    );
  }

  Widget _otpTextField(TextEditingController controller) {
    return SizedBox(
      width: 50,
      child: TextField(
        controller: controller,
        textAlign: TextAlign.center,
        maxLength: 1,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          counterText: '',
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.purple.shade200),
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.purple),
            borderRadius: BorderRadius.circular(10),
          ),
          filled: true,
          fillColor: Colors.purple.shade100,
        ),
      ),
    );
  }
}
