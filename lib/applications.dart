// applications.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';

class ApplicationsPage extends StatefulWidget {
  const ApplicationsPage({super.key, required this.jobID});

  final int jobID;

  @override
  _ApplicationsPageState createState() => _ApplicationsPageState();
}

class _ApplicationsPageState extends State<ApplicationsPage> {
  late Future<List<Map<String, dynamic>>> _applications;
  List<Map<String, dynamic>> _sortedApplications = [];

  @override
  void initState() {
    super.initState();
    _applications = fetchApplications(widget.jobID);
  }

  Future<List<Map<String, dynamic>>> fetchApplications(int jobID) async {
    try {
      final url = Uri.parse('http://127.0.0.1:39542/get_application/$jobID');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['data']);
      } else {
        throw Exception("Failed to load applications");
      }
    } catch (e) {
      print("Error fetching applications: $e");
      return [];
    }
  }

  void openCV(String cvUrl) async {
    if (await canLaunch(cvUrl)) {
      await launch(cvUrl, forceWebView: false, enableJavaScript: true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Could not open CV: $cvUrl")),
      );
    }
  }

  void sortApplications() async {
    try {
      final url =
          Uri.parse('http://127.0.0.1:39542/sort_applications/${widget.jobID}');
      final response = await http.post(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final sortedList =
            List<Map<String, dynamic>>.from(data['sorted_applications']);

        // Debugging: Print sorted data
        print("Sorted Applications: $sortedList");

        setState(() {
          _sortedApplications = sortedList;
        });
      } else {
        throw Exception("Failed to sort applications");
      }
    } catch (e) {
      print("Error sorting applications: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error sorting applications: $e")),
      );
    }
  }

  Widget _buildApplicantRow({
    required String name,
    required String cvUrl,
    required double score,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 20,
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: Colors.black),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Name: $name',
                    style: const TextStyle(
                      color: Colors.lightBlue,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Score: ${score.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () => openCV(cvUrl),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF4A148C),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text(
              'View CV',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4A148C), Color(0xFF4A148C)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Applications',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4A148C), Color(0xFF4A148C)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Divider(color: Colors.white, thickness: 1),
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: _applications,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error: ${snapshot.error}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text(
                          'No applications found.',
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    }

                    final applications = snapshot.data!;
                    return ListView.builder(
                      itemCount: _sortedApplications.isNotEmpty
                          ? _sortedApplications.length
                          : applications.length,
                      itemBuilder: (context, index) {
                        final application = _sortedApplications.isNotEmpty
                            ? _sortedApplications[index]
                            : applications[index];
                        return _buildApplicantRow(
                          name: application['name'] ?? 'Unknown',
                          cvUrl: application['cvPath'] ?? '',
                          score: application['score'] ?? 0.0,
                        );
                      },
                    );
                  },
                ),
              ),
              const Divider(color: Colors.white, thickness: 1),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  onPressed: sortApplications,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF4A148C),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15),
                  ),
                  child: const Text(
                    'Sort',
                    style: TextStyle(
                      color: Color(0xFF4A148C),
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
    );
  }
}
