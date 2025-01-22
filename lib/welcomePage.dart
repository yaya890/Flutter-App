import 'package:flutter/material.dart';
import 'logInPage.dart'; // Import the LoginPage file

class WelcomePage extends StatelessWidget {
  WelcomePage({super.key});

  /// Navigate to LoginPage with the selected role
  Future<void> _navigateToLoginPage(BuildContext context, String role) async {
    try {
      // Navigate to the LoginPage and pass the role as an argument
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LogInPage(role: role),
        ),
      );
    } catch (e) {
      debugPrint('An error occurred while navigating: $e');
      _showErrorDialog(
          context, 'An error occurred while navigating to the login page.');
    }
  }

  /// Show error dialog
  void _showErrorDialog(BuildContext context, String message) {
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
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF512DA8), Color(0xFF370662)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      "Elpis HR",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Welcome to the Future of HR",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 40),
                    _loginOption(
                      icon: Icons.admin_panel_settings,
                      title: "HR Managers",
                      description:
                          "Access HR tools integrated with AI for better management.",
                      onTap: () => _navigateToLoginPage(context, "HR Manager"),
                    ),
                    const SizedBox(height: 20),
                    _loginOption(
                      icon: Icons.person,
                      title: "Candidates",
                      description:
                          "Access faster and more efficient hiring process.",
                      onTap: () => _navigateToLoginPage(context, "Candidate"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _loginOption({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: const Color(0xFF6A1B9A),
              child: Icon(icon, size: 30, color: Colors.white),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white70),
          ],
        ),
      ),
    );
  }
}
