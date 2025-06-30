import 'package:flutter/material.dart';
import 'package:student_app/dashboard/all_homeworks_page.dart';
import 'package:student_app/dashboard/homework_detail_page.dart';
// import 'package:url_launcher/url_launcher.dart';

final List<Map<String, String>> recentHomeworks = [
  {
    'subject': 'Math',
    'title': 'Algebra Practice',
    'date': '24 June 2025',
    'url': 'url site',
  },
  {
    'subject': 'Science',
    'title': 'Chapter 5 Notes',
    'date': '23 June 2025',
    'url': 'https://example.com/homeworks/ch5.pdf',
  },
];

Widget buildRecentHomeworks(
  BuildContext context,
  List<Map<String, dynamic>> homeworks,
) {
  final limitedHomeworks = homeworks.take(3).toList();

  return Container(
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.2),
          blurRadius: 6,
          offset: Offset(0, 3),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '📝 Recent Homeworks',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AllHomeworksPage(homeworks: homeworks),
                  ),
                );
              },
              child: Text("View All"),
            ),
          ],
        ),
        SizedBox(height: 12),
        limitedHomeworks.isEmpty
            ? Text("No homeworks available.")
            : ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: limitedHomeworks.length,
                itemBuilder: (context, index) {
                  final hw = limitedHomeworks[index];
                  return ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => HomeworkDetailPage(homework: hw),
                        ),
                      );
                    },
                    leading: Icon(Icons.book, color: Colors.deepPurple),
                    title: Text(hw['HomeworkTitle'] ?? ''),
                    subtitle: Text('Submission: ${hw['SubmissionDate']}'),
                    trailing: hw['Attachment'] != null
                        ? Icon(Icons.download, color: Colors.deepPurple)
                        : SizedBox.shrink(),
                  );
                },
              ),
      ],
    ),
  );
}
