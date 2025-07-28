import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AssignSkillsPage extends StatefulWidget {
  const AssignSkillsPage({super.key});

  @override
  State<AssignSkillsPage> createState() => _AssignSkillsPageState();
}

class _AssignSkillsPageState extends State<AssignSkillsPage> {
  List<Map<String, dynamic>> studentList = [];
  List<Map<String, dynamic>> filteredList = [];
  List<Map<String, dynamic>> skills = [];
  List<Map<String, dynamic>> examList = [];
  String? selectedExam;

  bool isSubmitting = false;
  String? selectedSkill;
  bool showTable = false;
  bool isLoading = false;
  TextEditingController searchController = TextEditingController();
  Map<String, TextEditingController> gradeControllers = {};

  @override
  void initState() {
    super.initState();
    fetchExams();
    fetchSkills();
  }

  Future<void> fetchExams() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    try {
      final response = await http.post(
        Uri.parse('https://school.edusathi.in/api/get_exam'),
        headers: {
          'Content-Type': 'application/json',
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({}),
      );

      print("📘 Exam API Response: ${response.body}");

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = jsonDecode(response.body);
        setState(() {
          examList = List<Map<String, dynamic>>.from(jsonResponse);
        });
      } else {
        print("❌ Exam API failed: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Error fetching exams: $e");
    }
  }

  Future<void> fetchSkills() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    print("🔹 Fetching Skills...");

    try {
      final response = await http.post(
        Uri.parse('https://school.edusathi.in/api/get_skill'),
        headers: {
          'Content-Type': 'application/json',
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      );

      print("📥 Skill API Response Code: ${response.statusCode}");
      print("📥 Skill API Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = jsonDecode(response.body);
        print("✅ Decoded Skills: $jsonResponse");

        setState(() {
          skills = List<Map<String, dynamic>>.from(jsonResponse);
          print("📦 Skills Loaded into State: $skills");
        });
      } else {
        print(
          "❌ Failed to fetch skills: ${response.statusCode}, ${response.body}",
        );
      }
    } catch (e) {
      print("❌ Error fetching skills: $e");
    }
  }

  Future<void> _fetchStudents() async {
    print("🔹 Starting student fetch...");

    setState(() {
      isLoading = true;
      showTable = false;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final keys = prefs.getKeys();
      print("🧾 SharedPreferences keys: $keys");

      print("📤 Sending POST to Student Skill API...");

      print("➡️ SkillId: $selectedSkill");

      final resp = await http.post(
        Uri.parse('https://school.edusathi.in/api/teacher/skill'),
        headers: {
          "Content-Type": "application/json",
          if (token.isNotEmpty) "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "ExamId": int.parse(selectedExam ?? "0"),
          "SkillId": int.parse(selectedSkill!),
        }),
      );
      print("➡️ ExamId: $selectedExam");

      print("📥 Student Skill API Response Code: ${resp.statusCode}");
      print("📥 Response Body: ${resp.body}");

      final data = jsonDecode(resp.body);
      print("✅ Decoded JSON: $data");
      gradeControllers.clear();
      if (data['skills'] != null) {
        print("📋 Fetched Students with Grades:");

        for (var s in data['skills']) {
          print(
            "➡️ ${s['StudentName']} (Roll: ${s['RollNo']}), Grade: ${s['Grade']}, Status: ${s['Status']}",
          );
        }

        

        filteredList = List.from(studentList);
        // 💡 Create and sync controllers
        for (var student in filteredList) {
          final id = student['studentid'].toString();

          if (!gradeControllers.containsKey(id)) {
            gradeControllers[id] = TextEditingController(
              text: student['Grade'] ?? '',
            );
          } else {
            if (gradeControllers[id]!.text != (student['Grade'] ?? '')) {
              gradeControllers[id]!.text = student['Grade'] ?? '';
              gradeControllers[id]!.selection = TextSelection.fromPosition(
                TextPosition(offset: gradeControllers[id]!.text.length),
              );
            }
          }
        }

        setState(() {
          showTable = true;
          print("📊 Student List Ready. Count: ${studentList.length}");
        });
      } else {
        print("⚠️ No 'skills' data found in response.");
      }

      if (data['msg'] != null && data['msg'].toString().trim().isNotEmpty) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Notice'),
            content: Text(data['msg']),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      print("❌ Error fetching student skill data: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => isLoading = false);
      print("⏹️ Loading stopped.");
    }
  }

  Future<void> _submitSkills() async {
    setState(() => isSubmitting = true);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    try {
      // ✅ Validate first — stop if any Grade is empty
      final hasEmptyGrade = studentList.any(
        (student) =>
            student['Grade'] == null ||
            student['Grade'].toString().trim().isEmpty,
      );

      if (hasEmptyGrade) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Validation Error"),
            content: const Text(
              "Please enter Grade for all students before submitting.",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          ),
        );
        setState(() => isSubmitting = false); // reset loading
        return; // ❌ STOP here, don’t submit
      }

      // ✅ Now safe to prepare and send request
      final List<Map<String, dynamic>> skillEntries = studentList
          .map((s) => {"StudentId": s['studentid'], "Grade": s['Grade'] ?? ''})
          .toList();

      final response = await http.post(
        Uri.parse("https://school.edusathi.in/api/teacher/skill/store"),
        headers: {
          "Content-Type": "application/json",
          if (token.isNotEmpty) "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "ExamId": int.parse(selectedExam ?? "0"),
          "SkillId": int.parse(selectedSkill!),
          "skills": skillEntries,
        }),
      );

      final data = jsonDecode(response.body);
      print("📤 Submit Response: $data");

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Success'),
          content: Text(data['message'] ?? 'Skills updated'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      print("❌ Error during submission: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assign Skills'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DropdownButtonFormField<String>(
                            value: selectedExam,
                            decoration: InputDecoration(
                              labelText: 'Select Exam',
                              border: OutlineInputBorder(),
                            ),
                            items: examList.map((exam) {
                              if (examList.isNotEmpty)
                                selectedExam ??= examList.first['ExamId']
                                    .toString();

                              return DropdownMenuItem(
                                value: exam['ExamId'].toString(),
                                child: Text(exam['Exam']),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedExam = value;
                              });
                            },
                          ),
                          SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            value: selectedSkill,
                            decoration: InputDecoration(
                              labelText: 'Select Skill',
                              border: OutlineInputBorder(),
                            ),
                            items: skills
                                .map(
                                  (skill) => DropdownMenuItem(
                                    value: skill['SkillId'].toString(),
                                    child: Text(skill['Skill']),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) =>
                                setState(() => selectedSkill = val),
                          ),

                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton(
                              onPressed: selectedSkill == null
                                  ? null
                                  : _fetchStudents,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                              ),
                              child: const Text(
                                'Search',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (showTable) ...[
                    SizedBox(height: 12),
                    TextField(
                      controller: searchController,
                      decoration: const InputDecoration(
                        hintText: 'Search by name or roll',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (query) {
                        setState(() {
                          filteredList = studentList.where((s) {
                            final name = s['name'].toLowerCase();
                            final roll = s['roll'].toString();
                            return name.contains(query.toLowerCase()) ||
                                roll.contains(query);
                          }).toList();
                        });
                      },
                    ),
                    SizedBox(height: 12),

                    Expanded(
                      child: filteredList.isEmpty
                          ? const Center(
                              child: Text('No students found for this skill.'),
                            )
                          : ListView.builder(
                              itemCount: filteredList.length + 1,
                              itemBuilder: (context, index) {
                                if (index == filteredList.length) {
                                  // ✅ Show submit button after all student cards
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    child: isSubmitting
                                        ? const Center(
                                            child: CircularProgressIndicator(),
                                          )
                                        : SizedBox(
                                            width: double.infinity,
                                            child: ElevatedButton(
                                              onPressed: _submitSkills,
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Colors.deepPurple,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 14,
                                                    ),
                                              ),
                                              child: const Text(
                                                'Submit Skills',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                  );
                                }

                                final student = filteredList[index];
                                final isMarked =
                                    (student['Grade']
                                        ?.toString()
                                        .trim()
                                        .isNotEmpty ??
                                    false);
                                return Container(
                                  decoration: BoxDecoration(
                                    color: isMarked
                                        ? Colors.green.shade50
                                        : Colors.red.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isMarked
                                          ? Colors.green
                                          : Colors.red,

                                      width: 1.2,
                                    ),
                                  ),
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Roll No: ${student['roll']}  |  ${student['name']}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        Text(
                                          'Father: ${student['father']}',
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          maxLines: 1,
                                        ),
                                        SizedBox(height: 6),
                                        Row(
                                          children: [
                                            const Text('Grade:'),
                                            SizedBox(width: 8),
                                            SizedBox(
                                              width: 80,
                                              child: TextField(
                                                controller:
                                                    gradeControllers[student['studentid']
                                                        .toString()],
                                                decoration: InputDecoration(
                                                  hintText: 'Grade',
                                                  border: OutlineInputBorder(),
                                                  isDense: true,
                                                  contentPadding:
                                                      EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 8,
                                                      ),
                                                ),
                                                onChanged: (val) {
                                                  final grade = val
                                                      .trim()
                                                      .toUpperCase();
                                                  student['Grade'] = grade;

                                                
                                                  
                                                  student['status'] =
                                                      grade.isNotEmpty
                                                      ? 'Marked'
                                                      : 'Not Marked';
                                                  if (val.trim().isNotEmpty &&
                                                      student['status'] ==
                                                          'present') {
                                                    student['status'] =
                                                        'Marked';
                                                  } else {
                                                    student['status'] =
                                                        'Not Marked';
                                                  }
                                                  final idx = studentList
                                                      .indexWhere(
                                                        (s) =>
                                                            s['studentid'] ==
                                                            student['studentid'],
                                                      );

                                                  if (idx != -1) {
                                                    studentList[idx]['Grade'] =
                                                        val;
                                                    studentList[idx]['status'] =
                                                        student['status'];
                                                  }
                                                  setState(() {});
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}
