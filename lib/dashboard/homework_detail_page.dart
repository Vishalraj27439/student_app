import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:student_app/dashboard/homework_page.dart';

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

  Future<void> downloadFile(BuildContext context, String fileUrl) async {
    final status = await Permission.storage.request();
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Storage permission is required")),
      );
      return;
    }

    try {
      final response = await http.get(Uri.parse(fileUrl));
      if (response.statusCode == 200) {
        final dir = await getExternalStorageDirectory();
        final fileName = fileUrl.split('/').last;
        final file = File('${dir!.path}/$fileName');
        await file.writeAsBytes(response.bodyBytes);

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Downloaded to ${file.path}")));
        OpenFile.open(file.path);
      } else {
        throw Exception('Download failed');
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Download error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final attachment = homework['Attachment'];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Homework Detail"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomeworkPage()),
            );
          },
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    homework['HomeworkTitle'] ?? 'Untitled',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "📅 Assignment Date: ${formatDate(homework['WorkDate'])}",
                  ),
                  Text(
                    "📌 Submission Date: ${formatDate(homework['SubmissionDate'])}",
                  ),
                  const SizedBox(height: 12),
                  if ((homework['Remark'] ?? '').isNotEmpty) ...[
                    const Text(
                      "📝 Remark:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(homework['Remark']),
                  ],
                  const Spacer(),
                  if (attachment != null)
                    Center(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.download_rounded),
                        label: const Text("Download Attachment"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                        ),
                        onPressed: () => downloadFile(context, attachment),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
