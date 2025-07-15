
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ViewHomeworksPage extends StatelessWidget {
  final List<Map<String, dynamic>> homeworks;

  const ViewHomeworksPage({super.key, required this.homeworks});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Assigned Homeworks", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: homeworks.length,
        itemBuilder: (context, index) {
          final hw = homeworks[index];
          return Card(
            elevation: 3,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              title: Text(hw['HomeworkTitle'] ?? 'No Title'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Assign: ${_formatDate(hw['WorkDate'])}"),
                  Text("Submit: ${_formatDate(hw['SubmissionDate'])}"),
                  Text("Remark: ${hw['Remark'] ?? ''}"),
                ],
              ),
              trailing: hw['Attachment'] != null
                  ? IconButton(
                      icon: const Icon(Icons.download, color: Colors.deepPurple),
                      onPressed: () {
                        // TODO: Handle download logic
                      },
                    )
                  : null,
            ),
          );
        },
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '-';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd-MM-yyyy').format(date);
    } catch (_) {
      return dateStr;
    }
  }
}