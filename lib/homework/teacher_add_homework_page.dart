import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class TeacherAddHomeworkPage extends StatefulWidget {
  const TeacherAddHomeworkPage({super.key});

  @override
  State<TeacherAddHomeworkPage> createState() => _TeacherAddHomeworkPageState();
}

class _TeacherAddHomeworkPageState extends State<TeacherAddHomeworkPage> {
  List classes = [];
  List sections = [];
  int? selectedClassId;
  int? selectedSectionId;

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? assignDate;
  DateTime? submissionDate;
  File? selectedFile;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchClasses();
    final today = DateTime.now();
    assignDate = today;
    submissionDate = today;
  }

  Future<void> fetchClasses() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final response = await http.post(
      Uri.parse('https://school.edusathi.in/api/get_class'),
      headers: {
        'Authorization': 'Bearer $token', // ✅ Add this
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    print("🔵 Class API Status: ${response.statusCode}");
    print("🔵 Class API Response: ${response.body}");

    if (response.statusCode == 200) {
      setState(() {
        classes = jsonDecode(response.body);
      });
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to fetch classes")));
    }
  }

  Future<void> fetchSections(int classId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    print("🟢 Fetching sections for ClassId: $classId");

    final response = await http.post(
      Uri.parse('https://school.edusathi.in/api/get_section'),
      headers: {
        'Authorization': 'Bearer $token', // ✅ REQUIRED
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'ClassId': classId}),
    );

    print("🟢 Section API Status: ${response.statusCode}");
    print("🟢 Section API Response: ${response.body}");

    if (response.statusCode == 200) {
      setState(() {
        sections = jsonDecode(response.body);
        selectedSectionId = null;
      });
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to fetch sections")));
    }
  }

  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      setState(() {
        selectedFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> submitHomework() async {
    if (selectedClassId == null ||
        selectedSectionId == null ||
        assignDate == null ||
        submissionDate == null ||
        _titleController.text.isEmpty ||
        _descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
      return;
    }

    setState(() => isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final request =
        http.MultipartRequest(
            'POST',
            Uri.parse('https://school.edusathi.in/api/teacher/homework/store'),
          )
          ..headers['Authorization'] = 'Bearer $token'
          ..fields['Class'] = selectedClassId.toString()
          ..fields['Section'] = selectedSectionId.toString()
          ..fields['AssignDate'] = DateFormat('yyyy-MM-dd').format(assignDate!)
          ..fields['SubmissionDate'] = DateFormat(
            'yyyy-MM-dd',
          ).format(submissionDate!)
          ..fields['Title'] = _titleController.text
          ..fields['Description'] = _descriptionController.text;

    if (selectedFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath('Attachment', selectedFile!.path),
      );
    }

    final response = await request.send();
    final respStr = await response.stream.bytesToString();
    final decoded = jsonDecode(respStr);

    setState(() => isLoading = false);

    if (decoded['status'] == true) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(decoded['message'])));
      Navigator.pop(context, true); // go back
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(decoded['message'] ?? 'Upload failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Add Homework",
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
                  DropdownButtonFormField<int>(
                    decoration: const InputDecoration(labelText: "Class"),
                    value: selectedClassId,
                    items: classes.map((cls) {
                      return DropdownMenuItem<int>(
                        value: cls['id'],
                        child: Text(cls['Class']),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() => selectedClassId = val);
                      if (val != null) fetchSections(val);
                    },
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<int>(
                    decoration: const InputDecoration(labelText: "Section"),
                    value: selectedSectionId,
                    items: sections.map((sec) {
                      return DropdownMenuItem<int>(
                        value: sec['id'],
                        child: Text(sec['SectionName']),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => selectedSectionId = val),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: "Homework Title",
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(labelText: "Description"),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 10),

                  // Assign Date Section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Assign Date",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 6),
                      InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: assignDate ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setState(() {
                              assignDate = picked;
                            });
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                            horizontal: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                assignDate != null
                                    ? DateFormat(
                                        'dd-MM-yyyy',
                                      ).format(assignDate!)
                                    : DateFormat(
                                        'dd-MM-yyyy',
                                      ).format(DateTime.now()),
                                style: const TextStyle(fontSize: 16),
                              ),
                              const Icon(
                                Icons.calendar_today,
                                color: Colors.deepPurple,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Submission Date Section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Submission Date",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 6),
                      InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: submissionDate ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setState(() {
                              submissionDate = picked;
                            });
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                            horizontal: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                submissionDate != null
                                    ? DateFormat(
                                        'dd-MM-yyyy',
                                      ).format(submissionDate!)
                                    : DateFormat(
                                        'dd-MM-yyyy',
                                      ).format(DateTime.now()),
                                style: const TextStyle(fontSize: 16),
                              ),
                              const Icon(
                                Icons.calendar_today,
                                color: Colors.deepPurple,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Attachment (Optional)",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 5),
                      selectedFile == null
                          ? ElevatedButton.icon(
                              icon: const Icon(Icons.attach_file),
                              label: const Text("Choose File"),
                              onPressed: pickFile,
                            )
                          : Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.deepPurple),
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.deepPurple.withOpacity(0.05),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.insert_drive_file,
                                    color: Colors.deepPurple,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      selectedFile!.path.split('/').last,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.close,
                                      color: Colors.red,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        selectedFile = null;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                      ),
                      onPressed: submitHomework,
                      child: const Text(
                        "Submit Homework",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
