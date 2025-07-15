import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // Add this package
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';
import 'package:student_app/homework/homework_detail_page.dart';
import 'package:student_app/homework/homework_page.dart';
// import 'package:student_app/homework/teacher_homework_page.dart';

// Function to format the date
String formatDate(String? inputDate) {
  if (inputDate == null || inputDate.isEmpty) return '';
  try {
    final date = DateTime.parse(inputDate); // expects yyyy-MM-dd
    return DateFormat('dd-MM-yyyy').format(date);
  } catch (e) {
    return inputDate; // fallback to raw string
  }
}

Future<void> downloadFile(
  BuildContext context,
  String fileUrl,
  String fileName,
) async {
  if (Platform.isAndroid) {
    var status = await Permission.manageExternalStorage.request();
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Storage permission is required")),
      );
      return;
    }
  }

  try {
    final response = await http.get(Uri.parse(fileUrl));
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

Widget buildRecentHomeworks(
  BuildContext context,
  List<Map<String, dynamic>> homeworks,
) {
  final limitedHomeworks = homeworks.take(3).toList();

  return Container(
    padding: EdgeInsets.all(8),
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
                  MaterialPageRoute(builder: (_) => HomeworkPage()),
                );
              },
              child: Text("View All"),
            ),
          ],
        ),
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
                    title: Text(
                      hw['HomeworkTitle'] ?? '',
                      style: TextStyle(fontSize: 14),
                    ),
                    subtitle: Text(
                      'Submission: ${formatDate(hw['SubmissionDate'])}',
                      style: TextStyle(fontSize: 12),
                    ),
                    trailing: hw['Attachment'] != null
                        ? IconButton(
                            icon: Icon(
                              Icons.download,
                              color: Colors.deepPurple,
                            ),
                            onPressed: () {
                              String fileUrl = hw['Attachment'];
                              String fileName = fileUrl.split('/').last;

                              if (!fileUrl.startsWith('http')) {
                                fileUrl = 'https://school.edusathi.in/$fileUrl';
                              }

                              downloadFile(context, fileUrl, fileName);
                            },
                          )
                        : SizedBox.shrink(),
                  );
                },
              ),
      ],
    ),
  );
}
