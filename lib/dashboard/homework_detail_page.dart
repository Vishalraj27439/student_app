import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeworkDetailPage extends StatelessWidget {
  final Map<String, dynamic> homework;

  const HomeworkDetailPage({super.key, required this.homework});

  @override
  Widget build(BuildContext context) {
    TextStyle labelStyle = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 16,
      color: Colors.deepPurple,
    );
    TextStyle valueStyle = TextStyle(fontSize: 16);

    return Scaffold(
      appBar: AppBar(
        title: Text("Homework Details"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('📘 Title:', style: labelStyle),
            Text(homework['HomeworkTitle'] ?? 'N/A', style: valueStyle),
            SizedBox(height: 12),
            Text('📅 Submission Date:', style: labelStyle),
            Text(homework['SubmissionDate'] ?? 'N/A', style: valueStyle),
            SizedBox(height: 12),
            Text('📝 Remark:', style: labelStyle),
            Text(homework['Remark'] ?? 'No remark', style: valueStyle),
            SizedBox(height: 12),
            if (homework['Attachment'] != null)
              ElevatedButton.icon(
                onPressed: () async {
                  final url = homework['Attachment'];
                  final uri = Uri.parse(url);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Could not open attachment')),
                    );
                  }
                },
                icon: Icon(Icons.download),
                label: Text('Download Attachment'),
              )
            else
              Text(
                '📎 No attachment provided.',
                style: TextStyle(color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }
}
