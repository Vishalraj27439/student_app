import 'package:flutter/material.dart';

class SubjectsPage extends StatelessWidget {
  final List<Map<String, String>> subjects = [
    {'SubjectName': 'Mathematics'},
    {'SubjectName': 'English'},
    {'SubjectName': 'Science'},
    {'SubjectName': 'Social Studies'},
    {'SubjectName': 'Computer'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subjects', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        leading: const BackButton(color: Colors.white),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: subjects.length,
        itemBuilder: (context, index) {
          final subject = subjects[index];
          return Card(
            elevation: 3,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: const Icon(
                Icons.book_outlined,
                color: Colors.deepPurple,
              ),
              title: Text(
                subject['SubjectName'] ?? '',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          );
        },
      ),
    );
  }
}
