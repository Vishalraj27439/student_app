import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TeacherComplaintHistoryPage extends StatefulWidget {
  final int complaintId;
  final String date;
  final String description;
  final int status;

  const TeacherComplaintHistoryPage({
    super.key,
    required this.complaintId,
    required this.date,
    required this.description,
    required this.status,
  });

  @override
  State<TeacherComplaintHistoryPage> createState() =>
      _TeacherComplaintHistoryPageState();
}

class _TeacherComplaintHistoryPageState
    extends State<TeacherComplaintHistoryPage> {
  List<dynamic> history = [];
  bool isLoading = true;

  final String apiUrl =
      'https://school.edusathi.in/api/teacher/complaint/history';

  @override
  void initState() {
    super.initState();
    fetchComplaintHistory();
  }

  Future<void> fetchComplaintHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'ComplaintId': widget.complaintId}),
    );

    print("📥 Complaint History: ${response.body}");

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      if (decoded is List) {
        // Optional filtering logic if API returns extra history
        final filtered = decoded.where((entry) {
          final entryId = entry['ComplaintId'];
          return entryId == null ||
              entryId.toString() == widget.complaintId.toString();
        }).toList();

        setState(() {
          history = filtered;
          isLoading = false;
        });
      }
    } else {
      setState(() {
        history = [];
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load complaint history')),
      );
    }
  }

  String formatDate(String rawDate) {
    try {
      return DateFormat('dd-MM-yyyy').format(DateTime.parse(rawDate));
    } catch (_) {
      return rawDate;
    }
  }

  String getStatusText(int status) {
    return status == 1 ? "Solved" : "Pending";
  }

  Color getStatusColor(int status) {
    return status == 1 ? Colors.green : Colors.orange;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Complaint Details",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.deepPurple),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 📌 Original Complaint Card
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_today,
                                color: Colors.deepPurple,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                formatDate(widget.date),
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
                                    widget.status,
                                  ).withOpacity(0.1),
                                  border: Border.all(
                                    color: getStatusColor(widget.status),
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  getStatusText(widget.status),
                                  style: TextStyle(
                                    color: getStatusColor(widget.status),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            widget.description.replaceAll(r'\r\n', '\n'),
                            style: const TextStyle(fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  const Text(
                    "Complaint History",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  if (history.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 30),
                      child: Center(child: Text("No history found.")),
                    )
                  else
                    ...history.map(
                      (entry) => Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.timeline,
                                    size: 18,
                                    color: Colors.deepPurple,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    formatDate(entry['Date'] ?? ''),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                (entry['Description'] ?? '').replaceAll(
                                  r'\r\n',
                                  '\n',
                                ),
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
