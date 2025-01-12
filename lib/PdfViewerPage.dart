import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'dart:io';

class PdfViewerPage extends StatelessWidget {
  final String filePath;

  const PdfViewerPage({super.key, required this.filePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View CV'),
        backgroundColor: Colors.purple,
      ),
      body: FutureBuilder(
        future: File(filePath).exists(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError || !snapshot.data!) {
            return Center(
              child: Text(
                'Error: PDF file not found or cannot be opened.',
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else {
            return PDFView(
              filePath: filePath,
              enableSwipe: true,
              swipeHorizontal: false,
              autoSpacing: true,
              pageFling: true,
              onRender: (pages) {
                print('Document rendered with $pages pages.');
              },
              onError: (error) {
                print('PDFView Error: $error');
              },
              onPageError: (page, error) {
                print('Error on page $page: $error');
              },
            );
          }
        },
      ),
    );
  }
}
