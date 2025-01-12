import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UploadCVPage extends StatelessWidget {
  final int jobID;
  String? uploadedFilePath;

  UploadCVPage({super.key, required this.jobID});

  Future<void> _uploadCV(BuildContext context) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true,
      );

      if (result != null) {
        String fileName = result.files.single.name;

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const Center(child: CircularProgressIndicator()),
        );

        var request = http.MultipartRequest(
          'POST',
          Uri.parse('http://127.0.0.1:39542/upload_cv'),
        );
        request.fields['jobID'] = jobID.toString();

        if (result.files.single.bytes != null) {
          request.files.add(
            http.MultipartFile.fromBytes(
              'file',
              result.files.single.bytes!,
              filename: fileName,
            ),
          );
        } else if (result.files.single.path != null) {
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

        var response = await request.send();
        Navigator.of(context).pop();

        if (response.statusCode == 201) {
          var responseBody = await response.stream.bytesToString();
          var responseData = jsonDecode(responseBody);
          uploadedFilePath = responseData['file_path'];

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
      Navigator.of(context).pop();
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
      var response = await http.post(
        Uri.parse('http://127.0.0.1:39542/save_application'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "jobID": jobID,
          "filePath": uploadedFilePath,
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Application submitted successfully")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Failed to submit application: ${response.body}")),
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
      backgroundColor: const Color(0xFF6A1B9A), // Purple background
      body: SafeArea(
        child: Stack(
          children: [
            // Background
            Positioned.fill(
              child: CustomPaint(
                painter: BackgroundPainter(),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Title
                const Text(
                  'Application',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  height: 2,
                  width: 100,
                  color: Colors.white.withOpacity(0.7),
                ),
                const SizedBox(height: 40),

                // Upload Icon
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  child: const Icon(
                    Icons.upload_file,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),

                // Instructional Text
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    'Upload your CV and submit your application to take the first step toward your dream job!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _uploadCV(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF6A1B9A),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      icon: const Icon(Icons.upload),
                      label: const Text('Upload CV'),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton.icon(
                      onPressed: () => _submitApplication(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      icon: const Icon(Icons.send),
                      label: const Text('Submit'),
                    ),
                  ],
                ),
              ],
            ),
            // Footer
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Text(
                'Your future starts here!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..color = Colors.white.withOpacity(0.1);
    canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.3), 100, paint);
    canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.4), 150, paint);
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.8), 200, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
