import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class UploadCVPage extends StatelessWidget {
  final int jobID;
  String? uploadedFilePath; // To store the uploaded file path

  UploadCVPage({Key? key, required this.jobID}) : super(key: key);

  Future<void> _uploadCV(BuildContext context) async {
    try {
      // Open file picker to select a PDF
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'], // Restrict to PDF
        withData: true, // Required for web
      );

      if (result != null) {
        String fileName = result.files.single.name;

        // Show loading indicator
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const Center(child: CircularProgressIndicator()),
        );

        // Prepare request
        var request = http.MultipartRequest(
          'POST',
          Uri.parse('http://127.0.0.1:39542/upload_cv'),
        );
        request.fields['jobID'] = jobID.toString();

        if (result.files.single.bytes != null) {
          // For web: Use bytes
          request.files.add(
            http.MultipartFile.fromBytes(
              'file',
              result.files.single.bytes!,
              filename: fileName,
            ),
          );
        } else if (result.files.single.path != null) {
          // For mobile/desktop: Use file path
          request.files.add(
            await http.MultipartFile.fromPath(
              'file',
              result.files.single.path!,
              filename: fileName,
            ),
          );
        } else {
          throw Exception("File data is unavailable.");
        }

        // Send request
        var response = await request.send();
        Navigator.of(context).pop(); // Close loading dialog

        if (response.statusCode == 201) {
          var responseBody = await response.stream.bytesToString();
          var responseData = jsonDecode(responseBody);
          uploadedFilePath = responseData['file_path']; // Save the uploaded file path

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("CV uploaded successfully")),
          );
        } else {
          var responseBody = await response.stream.bytesToString();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to upload CV: $responseBody")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No file selected.")),
        );
      }
    } catch (e) {
      Navigator.of(context).pop(); // Close loading dialog if an error occurs
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred: $e")),
      );
    }
  }

  Future<void> _submitApplication(BuildContext context) async {
    if (uploadedFilePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please upload a CV first.")),
      );
      return;
    }

    try {
      // Prepare request
      var response = await http.post(
        Uri.parse('http://127.0.0.1:39542/save_application'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "jobID": jobID,
          "filePath": uploadedFilePath, // Pass the uploaded file path
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Application submitted successfully")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to submit application: ${response.body}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(Icons.menu),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.person)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.share)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
        ],
        title: const Text("Application"),
        centerTitle: true,
        backgroundColor: Colors.purple,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple, Colors.purpleAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            Center(
              child: Icon(
                Icons.upload_file,
                size: 200,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => _submitApplication(context),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    backgroundColor: Colors.purple.shade300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    "Submit",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () => _uploadCV(context),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    backgroundColor: Colors.purple.shade300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    "Upload CV",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

