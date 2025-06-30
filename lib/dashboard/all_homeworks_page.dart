import 'package:flutter/material.dart';

class AllHomeworksPage extends StatelessWidget {
  final List<Map<String, dynamic>> homeworks;

  const AllHomeworksPage({super.key, required this.homeworks});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("All Homeworks"),
        backgroundColor: Colors.deepPurple,
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(12),
        itemCount: homeworks.length,
        itemBuilder: (context, index) {
          final hw = homeworks[index];
          return Card(
            margin: EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: Icon(Icons.assignment, color: Colors.deepPurple),
              title: Text(hw['HomeworkTitle'] ?? ''),
              subtitle: Text("Due: ${hw['SubmissionDate']}"),
              trailing: hw['Attachment'] != null
                  ? Icon(Icons.download, color: Colors.deepPurple)
                  : SizedBox.shrink(),
              onTap: () {
                // Optionally navigate to homework detail page
              },
            ),
          );
        },
      ),
    );
  }
}
