import 'package:flutter/material.dart';

class TeacherHomeworkDetailPage extends StatelessWidget {
  final Map<String, dynamic> homework;

  const TeacherHomeworkDetailPage({super.key, required this.homework});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: const Text(
          'Homework Details',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "📝 Title: ${homework['HomeworkTitle'] ?? ''}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text("📅 Work Date: ${homework['WorkDate'] ?? ''}"),
            Text("📆 Submission Date: ${homework['SubmissionDate'] ?? ''}"),
            const SizedBox(height: 10),
            Text("🗒️ Remark:\n${homework['Remark'] ?? ''}"),
            const SizedBox(height: 20),
            if (homework['Attachment'] != null)
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: Add file open/download
                },
                icon: const Icon(Icons.download),
                label: const Text("Download Attachment"),
              ),
          ],
        ),
      ),
    );
  }
}
