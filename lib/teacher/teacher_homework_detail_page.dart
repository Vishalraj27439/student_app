import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

class TeacherHomeworkDetailPage extends StatelessWidget {
  final Map<String, dynamic> homework;

  const TeacherHomeworkDetailPage({super.key, required this.homework});

  String formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      return "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}";
    } catch (e) {
      return dateStr;
    }
  }

  Future<void> requestStoragePermission() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final sdkInt = androidInfo.version.sdkInt;

      if (sdkInt >= 33) {
        await [
          Permission.photos,
          Permission.videos,
          Permission.audio,
        ].request();
      } else {
        await Permission.storage.request();
      }
    }
  }

  Future<void> downloadFile(
    BuildContext context,
    String url,
    String fileName,
  ) async {
    try {
      final dir = await getExternalStorageDirectory();
      final filePath = '${dir!.path}/$fileName';

      final response = await http.get(Uri.parse(url));
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("📥 Downloaded to $filePath")));

      await OpenFile.open(filePath);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("❌ Download failed")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final attachment = homework['Attachment'];
    final fileName = attachment != null ? attachment.split('/').last : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(homework['HomeworkTitle'] ?? 'Homework Detail'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  homework['HomeworkTitle'] ?? 'Untitled',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(height: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("📅 Work Date: ${formatDate(homework['WorkDate'])}"),
                    const SizedBox(height: 4),
                    Text(
                      "🕒 Submission: ${formatDate(homework['SubmissionDate'])}",
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                const Text(
                  "📝 Remark:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(homework['Remark'] ?? 'No remarks provided'),
                const SizedBox(height: 20),
                if (attachment != null)
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                      ),
                      onPressed: () async {
                        await requestStoragePermission();
                        final fileUrl =
                            'https://school.edusathi.in/$attachment';
                        await downloadFile(context, fileUrl, fileName!);
                      },
                      icon: const Icon(Icons.download, color: Colors.white),
                      label: const Text(
                        "Download Attachment",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
