import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:student_app/complaint_detail_page.dart';
import 'package:student_app/dashboard/dashboard_screen.dart';

class ViewComplaintPage extends StatefulWidget {
  const ViewComplaintPage({super.key});

  @override
  State<ViewComplaintPage> createState() => _ViewComplaintPageState();
}

class _ViewComplaintPageState extends State<ViewComplaintPage> {
  final String apiUrl = 'https://school.edusathi.in/api/student/complaint';
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
    print(" Token: $token");

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    print("📥 Complaint API Response: ${response.body}");

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Complaints',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const DashboardScreen()),
            );
          },
        ),
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
                final status = complaint['Status'];

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => ComplaintDetailPage(
      complaintId: complaint['id'],
      date: complaint['Date'],
      description: complaint['Description'],
      status: complaint['Status'],
    ),
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
                                complaint['Date'] ?? '',
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
                                    status,
                                  ).withOpacity(0.1),
                                  border: Border.all(
                                    color: getStatusColor(status),
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  getStatusText(status),
                                  style: TextStyle(
                                    color: getStatusColor(status),
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
    );
  }
}
