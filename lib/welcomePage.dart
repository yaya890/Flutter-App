import 'package:flutter/material.dart';
import 'logInPage.dart'; // Import the LoginPage file
import 'candidate_home_screen.dart'; 

class WelcomePage extends StatelessWidget {
  const WelcomePage({Key? key}) : super(key: key);

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
          _animatedCircle(150, const Offset(-50, -50),
              const Color(0xFFD1C4E9).withOpacity(0.2)),
          _animatedCircle(250, const Offset(200, 400),
              const Color(0xFF9575CD).withOpacity(0.3)),
          _animatedCircle(100, const Offset(-80, 300),
              const Color(0xFFF8BBD0).withOpacity(0.2)),
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
                      description: "Access HR tools integrated with AI for better management.",
                      onTap: () {
                        // Navigate to LogInPage
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LogInPage(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    _loginOption(
                      icon: Icons.person,
                      title: "Candidates",
                      description:
                          "Access faster and more efficient hiring process .",
                      onTap: () {
                        // Navigate to LogInPage
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CandidateHomeScreen(),
                          ),
                        );
                      },
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

  Widget _animatedCircle(double size, Offset offset, Color color) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(seconds: 3),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(offset.dx * value, offset.dy * value),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
          ),
        );
      },
    );
  }
}
