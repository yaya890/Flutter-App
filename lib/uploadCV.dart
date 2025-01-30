// uploadCV.dart
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'available_jobs.dart';

class UploadCVPage extends StatefulWidget {
  const UploadCVPage({super.key, required this.jobID, required this.userData});

  final int jobID;
  final Map<String, dynamic> userData;

  @override
  _UploadCVPageState createState() => _UploadCVPageState();
}

class _UploadCVPageState extends State<UploadCVPage> {
  String? uploadedFilePath;

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
        request.fields['jobID'] = widget.jobID.toString();

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
        Navigator.of(context).pop(); // Close loading spinner

        var responseBody = await response.stream.bytesToString();
        var responseData = jsonDecode(responseBody);

        String message = response.statusCode == 201
            ? "CV uploaded successfully: ${responseData['file_path']}"
            : "Failed to upload CV: ${responseData['error']}";

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(response.statusCode == 201 ? "Success" : "Error"),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("OK"),
              ),
            ],
          ),
        );

        if (response.statusCode == 201) {
          uploadedFilePath = responseData['file_path'];
        }
      } else {
        _showMessageDialog(
            "No File Selected", "Please select a PDF file to upload.");
      }
    } catch (e) {
      Navigator.of(context).pop();
      _showMessageDialog("Error", "An error occurred: $e");
    }
  }

  Future<void> _submitApplication(BuildContext context) async {
    if (uploadedFilePath == null) {
      _showMessageDialog("Missing CV", "Please upload a CV first.");
      return;
    }

    try {
      var email = widget.userData['email'];

      var response = await http.post(
        Uri.parse('http://127.0.0.1:39542/save_application'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "jobID": widget.jobID,
          "email": email,
          "filePath": uploadedFilePath,
        }),
      );

      if (response.statusCode == 201) {
        _showMessageDialog("Success", "Application submitted successfully",
            onConfirm: () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
                builder: (context) => AvailableJobs(
                      userData: widget.userData,
                    )),
          );
        });
      } else {
        _showMessageDialog(
            "Error", "Failed to submit application: ${response.body}");
      }
    } catch (e) {
      _showMessageDialog("Error", "An error occurred: $e");
    }
  }

  void _showMessageDialog(String title, String message,
      {VoidCallback? onConfirm}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (onConfirm != null) onConfirm();
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF6A1B9A),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: BackgroundPainter(),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
