// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

// class MarkAttendancePage extends StatefulWidget {
//   const MarkAttendancePage({super.key});

//   @override
//   State<MarkAttendancePage> createState() => _MarkAttendancePageState();
// }

// class _MarkAttendancePageState extends State<MarkAttendancePage> {
//   DateTime selectedDate = DateTime.now();
//   TextEditingController searchController = TextEditingController();
//   String selectedCommonStatus = "P"; // default status for common bar

//   List<Map<String, String>> students = List.generate(10, (index) {
//     return {
//       "roll": "${index + 1}",
//       "name": "Student ${index + 1}",
//       "father": "Father ${index + 1}",
//       "status": "P",
//     };
//   });

//   List<Map<String, String>> filteredStudents = [];

//   @override
//   void initState() {
//     super.initState();
//     filteredStudents = List.from(students);
//   }

//   void filterSearch(String query) {
//     setState(() {
//       filteredStudents = students
//           .where(
//             (s) =>
//                 s['name']!.toLowerCase().contains(query.toLowerCase()) ||
//                 s['roll']!.contains(query),
//           )
//           .toList();
//     });
//   }

//   void pickDate() async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: selectedDate,
//       firstDate: DateTime(2023),
//       lastDate: DateTime.now(),
//     );
//     if (picked != null) {
//       setState(() {
//         selectedDate = picked;
//       });
//     }
//   }

//   void markAll(String status) {
//     setState(() {
//       selectedCommonStatus = status;
//       for (var student in students) {
//         student['status'] = status;
//       }
//       filterSearch(searchController.text); // Refresh filtered list
//     });
//   }

//   void markSingle(int index, String status) {
//     setState(() {
//       filteredStudents[index]['status'] = status;

//       // Update original list too
//       final roll = filteredStudents[index]['roll'];
//       final idx = students.indexWhere((s) => s['roll'] == roll);
//       if (idx != -1) {
//         students[idx]['status'] = status;
//       }
//     });
//   }

//   Color getColor(String status) {
//     switch (status) {
//       case "A":
//         return Colors.red;
//       case "P":
//         return Colors.green;
//       case "L":
//         return Colors.orange;
//       case "H":
//         return Colors.grey;
//       default:
//         return Colors.black;
//     }
//   }

//   Widget buildCircleButton(String label, String status) {
//     bool isSelected = selectedCommonStatus == status;
//     return GestureDetector(
//       onTap: () => markAll(status),
//       child: Container(
//         margin: const EdgeInsets.symmetric(horizontal: 6),
//         decoration: BoxDecoration(
//           shape: BoxShape.circle,
//           color: isSelected ? getColor(status) : Colors.grey.shade300,
//         ),
//         padding: const EdgeInsets.all(12),
//         child: Text(
//           label,
//           style: TextStyle(
//             color: isSelected ? Colors.white : Colors.black,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget buildStatusButton(
//     String label,
//     String status,
//     VoidCallback onTap,
//     bool isSelected,
//   ) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         margin: const EdgeInsets.symmetric(horizontal: 2),
//         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//         decoration: BoxDecoration(
//           color: getColor(status).withOpacity(isSelected ? 1 : 0.4),
//           borderRadius: BorderRadius.circular(6),
//         ),
//         child: Text(
//           label,
//           style: const TextStyle(
//             color: Colors.white,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Mark Attendance"),
//         backgroundColor: Colors.deepPurple,
//         iconTheme: const IconThemeData(color: Colors.white),
//         foregroundColor: Colors.white,
//       ),
//       body: Column(
//         children: [
//           // Date Picker Row
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               children: [
//                 const Icon(Icons.calendar_today, color: Colors.deepPurple),
//                 const SizedBox(width: 10),
//                 Text("Date: ${DateFormat('dd-MM-yyyy').format(selectedDate)}"),
//                 const Spacer(),
//                 ElevatedButton.icon(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.deepPurple,
//                   ),
//                   onPressed: pickDate,
//                   icon: const Icon(Icons.edit_calendar, color: Colors.white),
//                   label: const Text(
//                     "Pick Date",
//                     style: TextStyle(color: Colors.white),
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // Search Bar
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 8.0),
//             child: TextField(
//               controller: searchController,
//               decoration: InputDecoration(
//                 hintText: "Search student...",
//                 prefixIcon: const Icon(Icons.search, color: Colors.deepPurple),
//                 filled: true,
//                 fillColor: Colors.deepPurple.shade50, // Optional background

//                 enabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(25),
//                   borderSide: const BorderSide(color: Colors.deepPurple),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(25),
//                   borderSide: const BorderSide(
//                     color: Colors.deepPurple,
//                     width: 2,
//                   ),
//                 ),
//               ),
//               onChanged: filterSearch,
//             ),
//           ),

//           // Common Attendance Status Bar
//           Container(
//             margin: const EdgeInsets.symmetric(vertical: 10),
//             padding: const EdgeInsets.symmetric(vertical: 8),
//             color: Colors.grey.shade100,
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 buildCircleButton("A", "A"),
//                 buildCircleButton("P", "P"),
//                 buildCircleButton("L", "L"),
//                 buildCircleButton("H", "H"),
//               ],
//             ),
//           ),

//           // Student List with individual status
//           Expanded(
//             child: ListView.builder(
//               itemCount: filteredStudents.length,
//               itemBuilder: (context, index) {
//                 var student = filteredStudents[index];
//                 return Card(
//                   margin: const EdgeInsets.symmetric(
//                     horizontal: 8,
//                     vertical: 4,
//                   ),
//                   child: ListTile(
//                     title: Text("${student['roll']}. ${student['name']}"),
//                     subtitle: Text("Father: ${student['father']}"),
//                     trailing: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         buildStatusButton(
//                           "A",
//                           "A",
//                           () => markSingle(index, "A"),
//                           student['status'] == "A",
//                         ),
//                         buildStatusButton(
//                           "P",
//                           "P",
//                           () => markSingle(index, "P"),
//                           student['status'] == "P",
//                         ),
//                         buildStatusButton(
//                           "L",
//                           "L",
//                           () => markSingle(index, "L"),
//                           student['status'] == "L",
//                         ),
//                         buildStatusButton(
//                           "H",
//                           "H",
//                           () => markSingle(index, "H"),
//                           student['status'] == "H",
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),

//           // Submit Button
//           Padding(
//             padding: const EdgeInsets.all(12.0),
//             child: SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.deepPurple,
//                   padding: const EdgeInsets.symmetric(vertical: 14),
//                 ),
//                 onPressed: () {
//                   // TODO: Submit attendance data to API
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(content: Text("Attendance Submitted")),
//                   );
//                 },
//                 child: const Text(
//                   "Submit Attendance",
//                   style: TextStyle(fontSize: 16, color: Colors.white),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MarkAttendancePage extends StatefulWidget {
  const MarkAttendancePage({super.key});

  @override
  State<MarkAttendancePage> createState() => _MarkAttendancePageState();
}

class _MarkAttendancePageState extends State<MarkAttendancePage> {
  DateTime selectedDate = DateTime.now();
  TextEditingController searchController = TextEditingController();
  String selectedCommonStatus = "P";
  List<Map<String, dynamic>> students = [];
  List<Map<String, dynamic>> filteredStudents = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  void filterSearch(String query) {
    setState(() {
      filteredStudents = students
          .where(
            (s) =>
                s['StudentName'].toLowerCase().contains(query.toLowerCase()) ||
                s['RollNo'].toString().contains(query),
          )
          .toList();
    });
  }

  void pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
      fetchStudents();
    }
  }

  void markAll(String status) {
    setState(() {
      selectedCommonStatus = status;
      for (var student in students) {
        student['Status'] = status;
      }
      filterSearch(searchController.text);
    });
  }

  void markSingle(int index, String status) {
    setState(() {
      filteredStudents[index]['Status'] = status;
      final id = filteredStudents[index]['id'];
      final idx = students.indexWhere((s) => s['id'] == id);
      if (idx != -1) {
        students[idx]['Status'] = status;
      }
    });
  }

  Future<void> fetchStudents() async {
    setState(() => isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? "";

    final response = await http.post(
      Uri.parse('https://school.edusathi.in/api/teacher/std_attendance'),
      headers: {'Authorization': 'Bearer $token'},
      body: {'Date': DateFormat('yyyy-MM-dd').format(selectedDate)},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      students = List<Map<String, dynamic>>.from(data);
      filteredStudents = List.from(students);
    } else {
      students = [];
      filteredStudents = [];
    }
    setState(() => isLoading = false);
  }

  Future<void> submitAttendance() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? "";

    final payload = {
      "AttendanceDate": DateFormat('yyyy-MM-dd').format(selectedDate),
      "Attendance": students
          .map(
            (student) => {
              "StudentId": student['id'],
              "Status": student['Status'],
            },
          )
          .toList(),
    };

    final response = await http.post(
      Uri.parse('https://school.edusathi.in/api/teacher/std_attendance/store'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(payload),
    );

    final result = jsonDecode(response.body);
    if (result['status']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Attendance submitted')),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Submission failed")));
    }
  }

  Color getColor(String status) {
    switch (status) {
      case "A":
        return Colors.red;
      case "P":
        return Colors.green;
      case "L":
        return Colors.orange;
      case "H":
        return Colors.grey;
      default:
        return Colors.black;
    }
  }

  Widget buildCircleButton(String label, String status) {
    bool isSelected = selectedCommonStatus == status;
    return GestureDetector(
      onTap: () => markAll(status),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? getColor(status) : Colors.grey.shade300,
        ),
        padding: const EdgeInsets.all(12),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget buildStatusButton(
    String label,
    String status,
    VoidCallback onTap,
    bool isSelected,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: getColor(status).withOpacity(isSelected ? 1 : 0.4),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mark Attendance"),
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, color: Colors.deepPurple),
                const SizedBox(width: 10),
                Text("Date: ${DateFormat('dd-MM-yyyy').format(selectedDate)}"),
                const Spacer(),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                  ),
                  onPressed: pickDate,
                  icon: const Icon(Icons.edit_calendar, color: Colors.white),
                  label: const Text(
                    "Pick Date",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Search student...",
                prefixIcon: const Icon(Icons.search, color: Colors.deepPurple),
                filled: true,
                fillColor: Colors.deepPurple.shade50,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: const BorderSide(color: Colors.deepPurple),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: const BorderSide(
                    color: Colors.deepPurple,
                    width: 2,
                  ),
                ),
              ),
              onChanged: filterSearch,
            ),
          ),

          if (students.isNotEmpty)
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              padding: const EdgeInsets.symmetric(vertical: 8),
              color: Colors.grey.shade100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  buildCircleButton("A", "A"),
                  buildCircleButton("P", "P"),
                  buildCircleButton("L", "L"),
                  buildCircleButton("H", "H"),
                ],
              ),
            ),

          if (isLoading) const Center(child: CircularProgressIndicator()),
          if (!isLoading && students.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: filteredStudents.length,
                itemBuilder: (context, index) {
                  var student = filteredStudents[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: ListTile(
                      title: Text(
                        "${student['RollNo']}. ${student['StudentName'] ?? 'Name Missing'}",
                      ),
                      subtitle: Text("Father: ${student['FatherName'] ?? ''}"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          buildStatusButton(
                            "A",
                            "A",
                            () => markSingle(index, "A"),
                            student['Status'] == "A",
                          ),
                          buildStatusButton(
                            "P",
                            "P",
                            () => markSingle(index, "P"),
                            student['Status'] == "P",
                          ),
                          buildStatusButton(
                            "L",
                            "L",
                            () => markSingle(index, "L"),
                            student['Status'] == "L",
                          ),
                          buildStatusButton(
                            "H",
                            "H",
                            () => markSingle(index, "H"),
                            student['Status'] == "H",
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

          if (!isLoading && students.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: submitAttendance,
                  child: const Text(
                    "Submit Attendance",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
