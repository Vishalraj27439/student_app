import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class StudentAlertPage extends StatefulWidget {
  const StudentAlertPage({super.key});

  @override
  State<StudentAlertPage> createState() => _StudentAlertPageState();
}

class _StudentAlertPageState extends State<StudentAlertPage> {
  DateTime? selectedDate;
  TextEditingController searchController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController dateController = TextEditingController();

  List<dynamic> students = [];
  List<dynamic> filteredStudents = [];
  Set<String> selectedTokens = {};
  bool selectAll = false;
  bool isLoading = false;
  String? token;

  @override
  void initState() {
    super.initState();
    _loadTokenAndFetchStudents();
  }

  Future<void> _loadTokenAndFetchStudents() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString("token");
    await fetchStudents();
  }

  Future<void> fetchStudents() async {
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("⚠️ Token not found. Please login again."),
        ),
      );
      return;
    }

    setState(() => isLoading = true);
    final url = Uri.parse(
      "https://school.edusathi.in/api/teacher/student/list",
    );
    try {
      final res = await http.post(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: json.encode({}),
      );

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        debugPrint("📥 Raw Response: $data");
        debugPrint("📌 Total Students from API: ${data.length}");
        setState(() {
          students = data;
          filteredStudents = data;
        });
      } else {
        debugPrint("❌ Fetch failed: ${res.statusCode} - ${res.body}");

        debugPrint("📌 Total Students: ${students.length}");
      }
    } catch (e) {
      debugPrint("❌ Error fetching students: $e");
    }
    setState(() => isLoading = false);
  }

  void filterStudents(String query) {
    setState(() {
      filteredStudents = students
          .where(
            (s) => s["StudentName"].toString().toLowerCase().contains(
              query.toLowerCase(),
            ),
          )
          .toList();
    });
  }

  Future<void> sendAlert() async {
    final message = descriptionController.text.trim();

    if (message.isEmpty || selectedTokens.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("⚠️ Please enter message and select students"),
        ),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirm Send"),
        content: Text(
          "Are you sure you want to send this alert to ${selectedTokens.length} students?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
            ),
            child: const Text("Yes, Send"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("⚠️ Token not found. Please login again."),
        ),
      );
      return;
    }

    final url = Uri.parse(
      "https://school.edusathi.in/api/teacher/student/alert",
    );
    final body = {"message": message, "tokens": selectedTokens.toList()};

    try {
      final res = await http.post(
        url,
        body: json.encode(body),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (res.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Alert sent successfully!")),
        );
        descriptionController.clear();
        setState(() {
          selectedTokens.clear();
          selectAll = false;
        });
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("❌ Failed: ${res.body}")));
      }
    } catch (e) {
      debugPrint("❌ Error sending alert: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Alert"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Description Box
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: descriptionController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: "Write alert/description",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

                // Search Bar
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: searchController,
                    onChanged: filterStudents,
                    decoration: InputDecoration(
                      hintText: "Search Student by Name",
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Colors.deepPurple,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

                // Select All Checkbox
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    children: [
                      Checkbox(
                        value: selectAll,
                        activeColor: Colors.deepPurple,
                        onChanged: (val) {
                          setState(() {
                            selectAll = val ?? false;
                            if (selectAll) {
                              selectedTokens = filteredStudents
                                  .map<String>((s) => s["fcm_token"].toString())
                                  .toSet();
                            } else {
                              selectedTokens.clear();
                            }
                          });
                        },
                      ),
                      const Text("Select All Students"),
                    ],
                  ),
                ),

                // Student List
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredStudents.length,
                    itemBuilder: (context, index) {
                      final student = filteredStudents[index];
                      final token = student["fcm_token"].toString();
                      final isSelected = selectedTokens.contains(token);

                      return Card(
                        color: isSelected
                            ? Colors.deepPurple[50]
                            : Colors.white,
                        margin: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: ListTile(
                          leading: Checkbox(
                            value: isSelected,
                            activeColor: Colors.deepPurple,
                            onChanged: (val) {
                              setState(() {
                                if (val == true) {
                                  selectedTokens.add(token);
                                } else {
                                  selectedTokens.remove(token);
                                }
                                selectAll =
                                    selectedTokens.length ==
                                    filteredStudents.length;
                              });
                            },
                          ),
                          title: Text(student["StudentName"]),
                          subtitle: Text(
                            "Father: ${student["FatherName"]}\n"
                            "Roll: ${student["RollNo"]} | DOB: ${student["DOB"]}",
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Send Alert Button
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: sendAlert,
                      icon: const Icon(Icons.send),
                      label: const Text("Send Alert"),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
