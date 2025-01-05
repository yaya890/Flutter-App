import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

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

  void openCV(BuildContext context, String cvUrl) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/temp.pdf';

      // Debugging logs
      print("Downloading CV from: $cvUrl");
      print("Saving to: $filePath");

      final response = await http.get(Uri.parse(cvUrl));
      if (response.statusCode == 200) {
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        // Check if the file exists
        if (await file.exists()) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PdfViewerPage(pdfUrl: cvUrl),
            ),
          );
        } else {
          throw Exception("Downloaded file does not exist.");
        }
      } else {
        throw Exception("Failed to download the CV.");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error opening CV: $e")),
      );
    }
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
          Row(
            children: [
              const CircleAvatar(
                radius: 20,
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: Colors.black),
              ),
              const SizedBox(width: 10),
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
  final String filePath;

  const PdfViewerPage({Key? key, required this.filePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View CV'),
        backgroundColor: Colors.purple,
      ),
      body: PDFView(
        filePath: filePath,
        enableSwipe: true,
        swipeHorizontal: false,
        autoSpacing: true,
        pageFling: true,
        onError: (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error loading PDF: $error")),
          );
        },
      ),
    );
  }
}
