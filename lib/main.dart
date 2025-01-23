// main.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'welcomePage.dart'; // Ensure this file is in the same directory or update the import path.

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://gxfktitynhoajtnnflkr.supabase.co', // Your Supabase URL
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imd4Zmt0aXR5bmhvYWp0bm5mbGtyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzc1NDgzOTMsImV4cCI6MjA1MzEyNDM5M30.gOgJbAaVW9EGhMCnaAY_mxwU1rG82iLvvdVXVnNqW-A', // Your Supabase Anon Key
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Candidate App',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: WelcomePage(), // The home page of your app
    );
  }
}
