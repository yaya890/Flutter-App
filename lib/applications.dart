import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApplicationsPage extends StatefulWidget {
  final int jobID;

  const ApplicationsPage({Key? key, required this.jobID}) : super(key: key);

  @override
  _ApplicationsPageState createState() => _ApplicationsPageState();
}

class _ApplicationsPageState extends State<ApplicationsPage> {
  late Future<List<Map<String, dynamic>>> _applications;

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

  void openCV(BuildContext context, String cvPath) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PdfViewerPage(pdfUrl: cvPath),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4A148C), Color(0xFF7A1EA1)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // AppBar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.menu, color: Colors.white),
                      onPressed: () {},
                    ),
                    const Text(
                      'Applications',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.person, color: Colors.white),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),

              // Divider
              const Divider(color: Colors.white, thickness: 1),

              // Applicant List
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
                      itemCount: applications.length,
                      itemBuilder: (context, index) {
                        final application = applications[index];
                        return _buildApplicantRow(
                          name: application['name'] ?? 'Unknown',
                          cvUrl: application['cvPath'] ?? '',
                        );
                      },
                    );
                  },
                ),
              ),

              // Sort Button
              const Divider(color: Colors.white, thickness: 1),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: ElevatedButton(
                  onPressed: () {
                    // Sort functionality placeholder
                    debugPrint("Sort button pressed");
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.purple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
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

  Widget _buildApplicantRow({required String name, required String cvUrl}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Profile Icon
          Row(
            children: [
              const CircleAvatar(
                radius: 20,
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: Colors.black),
              ),
              const SizedBox(width: 10),

              // Name Placeholder
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
                ],
              ),
            ],
          ),

          // View CV Button
          ElevatedButton(
            onPressed: () => openCV(context, cvUrl),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.purple,
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
}

class PdfViewerPage extends StatelessWidget {
  final String pdfUrl;

  const PdfViewerPage({Key? key, required this.pdfUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View CV'),
        backgroundColor: Colors.purple,
      ),
      body: Center(
        child: Text(
          'CV Viewer for $pdfUrl\n\nPDF Viewing not implemented.',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18, color: Colors.black),
        ),
      ),
    );
  }
}
