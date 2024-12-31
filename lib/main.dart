import 'package:flutter/material.dart';
import 'verificationPage.dart';
import 'newJobPosting.dart';
import 'jobPostings.dart';
import 'applications.dart';
import 'forgotPassword.dart';
import 'logInPage.dart';
import 'welcomePage.dart'; // Import the WelcomePage

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter App',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: const WelcomePage(), // Set WelcomePage as the initial page
    );
  }
}
