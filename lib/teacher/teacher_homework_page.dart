// teacher_homework_page.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:student_app/teacher/teacher_homework_detail_page.dart';

class TeacherHomeworkPage extends StatefulWidget {
  const TeacherHomeworkPage({super.key});

  @override
  State<TeacherHomeworkPage> createState() => _TeacherHomeworkPageState();
}

class _TeacherHomeworkPageState extends State<TeacherHomeworkPage> {
  List<Map<String, dynamic>> homeworks = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchHomeworks();
  }

  Future<void> fetchHomeworks() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final response = await http.post(
      Uri.parse('https://school.edusathi.in/api/teacher/homework'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        homeworks = List<Map<String, dynamic>>.from(data);
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  String formatDate(String date) {
    try {
      return DateFormat('dd-MM-yyyy').format(DateTime.parse(date));
    } catch (e) {
      return date;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Homeworks'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : homeworks.isEmpty
              ? const Center(child: Text('No homework found.'))
              : ListView.builder(
                  itemCount: homeworks.length,
                  itemBuilder: (context, index) {
                    final hw = homeworks[index];
                    return ListTile(
                      title: Text(hw['HomeworkTitle'] ?? ''),
                      subtitle: Text('Submission: ${formatDate(hw['SubmissionDate'])}'),
                      trailing: hw['Attachment'] != null
                          ? const Icon(Icons.attach_file, color: Colors.deepPurple)
                          : null,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TeacherHomeworkDetailPage(homework: hw),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}
