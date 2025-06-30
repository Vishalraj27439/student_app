import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';

class HomeworkPage extends StatefulWidget {
  const HomeworkPage({super.key});

  @override
  State<HomeworkPage> createState() => _HomeworkPageState();
}

class _HomeworkPageState extends State<HomeworkPage> {
  List<dynamic> homeworks = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchHomework();
  }

  Future<void> fetchHomework() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final url = Uri.parse('https://school.edusathi.in/api/student/homework');

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({}), // empty body if nothing required
      );

      print('📡 Status Code: ${response.statusCode}');
      print('📄 Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          homeworks = data;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load homework');
      }
    } catch (e) {
      print('❌ Error: $e');
      setState(() {
        isLoading = false;
        homeworks = [];
      });
    }
  }

  String formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd-MM-yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  Future<void> downloadFile(String fileUrl, String fileName) async {
    final status = await Permission.storage.request();
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Storage permission is required")),
      );
      return;
    }

    try {
      final response = await http.post(Uri.parse(fileUrl));
      if (response.statusCode == 200) {
        final dir = await getExternalStorageDirectory();
        final file = File('${dir!.path}/$fileName');
        await file.writeAsBytes(response.bodyBytes);

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Downloaded to ${file.path}")));

        await OpenFile.open(file.path);
      } else {
        throw Exception('Download failed');
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Download error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Homework', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : homeworks.isEmpty
          ? const Center(child: Text("No homework available"))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: homeworks.length,
              itemBuilder: (context, index) {
                final hw = homeworks[index];
                final attachmentUrl = hw['Attachment'];
                final fileName = (attachmentUrl != null)
                    ? attachmentUrl.split('/').last
                    : "";

                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 📚 Homework Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                hw['HomeworkTitle'] ?? 'Untitled',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "📅 Assignment: ${formatDate(hw['WorkDate'])}",
                              ),
                              Text(
                                "📌 Submission: ${formatDate(hw['SubmissionDate'])}",
                              ),
                              const SizedBox(height: 6),
                              if ((hw['Remark'] ?? '').isNotEmpty)
                                Text("📝 ${hw['Remark']}"),
                            ],
                          ),
                        ),

                        // 📥 Download Icon if Attachment is not null
                        if (attachmentUrl != null)
                          IconButton(
                            icon: const Icon(
                              Icons.download_rounded,
                              color: Colors.deepPurple,
                            ),
                            onPressed: () {
                              downloadFile(attachmentUrl, fileName);
                            },
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
