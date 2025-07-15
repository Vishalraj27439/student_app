import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeworkDetailPage extends StatelessWidget {
  final Map<String, dynamic> homework;

  const HomeworkDetailPage({super.key, required this.homework});

  String formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd-MM-yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }
Future<void> downloadFile(BuildContext context, String filePath) async {
  if (Platform.isAndroid && await Permission.manageExternalStorage.request().isDenied) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Storage permission is required")),
    );
    return;
  }

  final fullUrl = 'https://school.edusathi.in/$filePath';

  try {
    final response = await http.get(Uri.parse(fullUrl));
    if (response.statusCode == 200) {
      final directory = await getExternalStorageDirectory(); // This is app-specific
      final fileName = filePath.split('/').last;
      final file = File('${directory!.path}/$fileName');
      await file.writeAsBytes(response.bodyBytes);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Downloaded to ${file.path}")),
      );

      await OpenFile.open(file.path);
    } else {
      throw Exception('Download failed');
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Download error: $e")),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    final attachment = homework['Attachment'];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Homework Detail",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              homework['HomeworkTitle'] ?? 'Untitled',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 16),

            // Assignment and Submission Dates in Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Assignment: ${formatDate(homework['WorkDate'])}",
                  style: const TextStyle(fontSize: 14),
                ),
                Text(
                  "Submission: ${formatDate(homework['SubmissionDate'])}",
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),

            const SizedBox(height: 20),

            if ((homework['Remark'] ?? '').isNotEmpty) ...[
              const Text(
                "📝 Remark:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(homework['Remark']),
              const SizedBox(height: 20),
            ],

            if (attachment != null)
              Center(
                child: ElevatedButton.icon(
                  onPressed: () => downloadFile(context, attachment),
                  icon: const Icon(Icons.download_rounded, color: Colors.white),
                  label: const Text(
                    "Download Attachment",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.deepPurple, // Change color if needed
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
