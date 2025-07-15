import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:student_app/teacher/complaint_teacher/teacher_add_complaint_page.dart';
import 'package:student_app/teacher/complaint_teacher/teacher_complaint_history_page.dart';

// import 'teacher_complaint_history_page.dart';

class TeacherComplaintListPage extends StatefulWidget {
  const TeacherComplaintListPage({super.key});

  @override
  State<TeacherComplaintListPage> createState() =>
      _TeacherComplaintListPageState();
}

class _TeacherComplaintListPageState extends State<TeacherComplaintListPage> {
  final String apiUrl = 'https://school.edusathi.in/api/teacher/complaint';
  List<dynamic> complaints = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchComplaints();
  }

  Future<void> fetchComplaints() async {
    setState(() => isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      setState(() {
        complaints = jsonDecode(response.body);
        isLoading = false;
      });
    } else {
      setState(() {
        complaints = [];
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load complaints')),
      );
    }
  }

  Color getStatusColor(int status) {
    return status == 1 ? Colors.green : Colors.orange;
  }

  String getStatusText(int status) {
    return status == 1 ? 'Solved' : 'Pending';
  }

  String formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd-MM-yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complaints', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.deepPurple),
            )
          : complaints.isEmpty
          ? const Center(child: Text('No complaints available'))
          : ListView.builder(
              itemCount: complaints.length,
              padding: const EdgeInsets.all(12),
              itemBuilder: (context, index) {
                final complaint = complaints[index];

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>TeacherComplaintHistoryPage(
  complaintId: (complaint['ComplaintId'] ?? 0) as int,
  date: (complaint['Date'] ?? '') as String,
  description: (complaint['Description'] ?? '') as String,
  status: (complaint['Status'] ?? 0) as int,
)

                      ),
                    );
                  },
                  child: Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.date_range,
                                color: Colors.deepPurple,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                formatDate(complaint['Date'] ?? ''),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: getStatusColor(
                                    complaint['Status'],
                                  ).withOpacity(0.1),
                                  border: Border.all(
                                    color: getStatusColor(complaint['Status']),
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  getStatusText(complaint['Status']),
                                  style: TextStyle(
                                    color: getStatusColor(complaint['Status']),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            complaint['Description']?.replaceAll(
                                  r"\r\n",
                                  "\n",
                                ) ??
                                '',
                            style: const TextStyle(fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => TeacherAddComplaintPage()),
          );
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('FAB pressed')));
        },
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
