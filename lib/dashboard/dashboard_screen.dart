// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:student_app/dashboard/attendance_pie_chart.dart';
// import 'package:student_app/dashboard/homework_model.dart';
// import 'package:student_app/dashboard/homework_page.dart';
// import 'package:student_app/dashboard/timetable_page.dart';
// import 'package:student_app/login_page.dart';
// import 'package:student_app/payment/fee_details_page.dart';
// import 'package:student_app/payment/payment_page.dart';
// import 'package:student_app/profile_page.dart';
// import 'package:student_app/school_info_page.dart';
// import 'package:student_app/complaint/view_complaints_page.dart';
// import 'package:student_app/subjects_page.dart';

// class DashboardScreen extends StatefulWidget {
//   const DashboardScreen({super.key});

//   @override
//   State<DashboardScreen> createState() => _DashboardScreenState();
// }

// class _DashboardScreenState extends State<DashboardScreen> {
//   bool isLoading = true;
//   String studentName = '';
//   String studentPhoto = '';
//   String schoolName = '';
//   String studentClass = '';
//   String studentSection = '';

//   int dues = 0;
//   int payments = 0;
//   int subjects = 0;
//   Map<String, dynamic> attendance = {};
//   List<Map<String, dynamic>> homeworks = [];

//   @override
//   void initState() {
//     super.initState();
//     loadProfileData();
//     fetchDashboardData();
//     // setState(() {
//     //   isLoading = false;
//     // });
//   }

//   Future<void> fetchDashboardData() async {
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('token') ?? '';

//     final response = await http.post(
//       Uri.parse('https://school.edusathi.in/api/student/dashboard'),
//       headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
//     );

//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);

//       setState(() {
//         dues = data['dues'] ?? 0;
//         payments = int.tryParse(data['payments'].toString()) ?? 0;
//         subjects = data['subjects'] ?? 0;
//         attendance = {
//           'present': data['attendances']?['present'] ?? 0,
//           'absent': data['attendances']?['absent'] ?? 0,
//           'leave': data['attendances']?['leave'] ?? 0,
//           'half_day': data['attendances']?['half_day'] ?? 0,
//           'working_days': data['attendances']?['working_days'] ?? 0,
//         };
//         homeworks = List<Map<String, dynamic>>.from(data['homeworks'] ?? []);
//       });
//     } else {
//       print('❌ Dashboard fetch failed: ${response.statusCode}');
//     }
//   }

//   void loadProfileData() async {
//     final prefs = await SharedPreferences.getInstance();
//     setState(() {
//       studentName = prefs.getString('student_name') ?? '';
//       studentPhoto = prefs.getString('student_photo') ?? '';
//       schoolName = prefs.getString('school_name') ?? '';
//       studentClass = prefs.getString('class_name') ?? '';
//       studentSection =
//           prefs.getString('class_section') ?? ''; //here chnges required
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       drawer: isLoading
//           ? null
//           : LeftSidebarMenu(
//               studentName: studentName,
//               schoolName: schoolName,
//               studentPhoto: studentPhoto,
//               studentClass: studentClass,
//               studentSection: studentSection,
//             ),
//       appBar: AppBar(
//         iconTheme: IconThemeData(color: Colors.white),
//         title: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(
//               schoolName.isEmpty ? 'Edusathi School' : schoolName,
//               style: TextStyle(color: Colors.white, fontSize: 16),
//             ),
//             CircleAvatar(
//               backgroundImage: studentPhoto.isNotEmpty
//                   ? NetworkImage(studentPhoto)
//                   : AssetImage('assets/images/logo.png') as ImageProvider,
//             ),
//           ],
//         ),
//         backgroundColor: Colors.deepPurple,
//       ),
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : SingleChildScrollView(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                     children: [
//                       DashboardCard(
//                         title: 'Dues',
//                         value: dues.toString(),
//                         borderColor: Colors.red,
//                         backgroundColor: Colors.red.shade50,
//                         textColor: Colors.red,
//                       ),
//                       DashboardCard(
//                         title: 'Payments',
//                         value: payments.toString(),
//                         borderColor: Colors.green,
//                         backgroundColor: Colors.green.shade50,
//                         textColor: Colors.green,
//                       ),
//                       GestureDetector(
//                         child: DashboardCard(
//                           title: 'Subjects',
//                           value: subjects.toString(),
//                           borderColor: Colors.blue,
//                           backgroundColor: Colors.blue.shade50,
//                           textColor: Colors.blue,
//                         ),
//                         onTap: () => Navigator.push(
//                           context,
//                           MaterialPageRoute(builder: (_) => SubjectsPage()),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 30),
//                   Container(
//                     height: 225,
//                     padding: const EdgeInsets.all(8),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(12),
//                       border: Border.all(color: Colors.deepPurple.shade100),
//                       boxShadow: [
//                         BoxShadow(color: Colors.grey.shade200, blurRadius: 6),
//                       ],
//                     ),
//                     child: AttendancePieChart(
//                       present: attendance['present'] ?? 0,
//                       absent: attendance['absent'] ?? 0,
//                       leave: attendance['leave'] ?? 0,
//                       halfDay: attendance['half_day'] ?? 0,
//                       workingDays: attendance['working_days'] ?? 0,
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                   buildRecentHomeworks(context, homeworks),
//                   const SizedBox(height: 10),
//                 ],
//               ),
//             ),

//       // ), body: isLoading
//       //   ? const Center(child: CircularProgressIndicator())
//       //   : SingleChildScrollView(
//       //       padding: const EdgeInsets.all(16),child: Column(

//       //       ),
//       //   body: SingleChildScrollView(
//       //     padding: EdgeInsets.all(16),
//       //     child: Column(
//       //       crossAxisAlignment: CrossAxisAlignment.start,
//       //       children: [
//       //         Row(
//       //           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//       //           children: [
//       //             DashboardCard(
//       //               title: 'Dues',
//       //               value: dues.toString(),
//       //               borderColor: Colors.red,
//       //               backgroundColor: Colors.red.shade50,
//       //               textColor: Colors.red,
//       //             ),
//       //             DashboardCard(
//       //               title: 'Payments',
//       //               value: payments.toString(),
//       //               borderColor: Colors.green,
//       //               backgroundColor: Colors.green.shade50,
//       //               textColor: Colors.green,
//       //             ),
//       //             GestureDetector(
//       //               child: DashboardCard(
//       //                 title: 'Subjects',
//       //                 value: subjects.toString(),
//       //                 borderColor: Colors.blue,
//       //                 backgroundColor: Colors.blue.shade50,
//       //                 textColor: Colors.blue,
//       //               ),
//       //               onTap: () => Navigator.push(
//       //                 context,
//       //                 MaterialPageRoute(builder: (_) => SubjectsPage()),
//       //               ),
//       //             ),
//       //           ],
//       //         ),
//       //         SizedBox(height: 30),

//       //         Container(
//       //           height: 225,
//       //           padding: EdgeInsets.all(8),
//       //           decoration: BoxDecoration(
//       //             color: Colors.white,
//       //             borderRadius: BorderRadius.circular(12),
//       //             border: Border.all(color: Colors.deepPurple.shade100),
//       //             boxShadow: [
//       //               BoxShadow(color: Colors.grey.shade200, blurRadius: 6),
//       //             ],
//       //           ),
//       //           child: AttendancePieChart(
//       //             present: attendance['present'] ?? 0,
//       //             absent: attendance['absent'] ?? 0,
//       //             leave: attendance['leave'] ?? 0,
//       //             halfDay: attendance['half_day'] ?? 0,
//       //             workingDays: attendance['working_days'] ?? 0,
//       //           ),
//       //         ),
//       //         SizedBox(height: 10),

//       //         buildRecentHomeworks(context, homeworks),

//       //         // buildNoticesEventsTab(),
//       //       ],
//       //     ),
//     );
//   }
// }

// class DashboardCard extends StatelessWidget {
//   final String title;
//   final String value;
//   final Color borderColor;
//   final Color backgroundColor;
//   final Color textColor;

//   DashboardCard({
//     required this.title,
//     required this.value,
//     required this.borderColor,
//     required this.backgroundColor,
//     required this.textColor,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 98,
//       height: 75,
//       margin: EdgeInsets.only(right: 10),
//       padding: EdgeInsets.all(6),
//       decoration: BoxDecoration(
//         color: backgroundColor,
//         border: Border.all(color: borderColor, width: 1.5),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Text(
//             title,
//             style: TextStyle(
//               fontWeight: FontWeight.bold,
//               color: textColor,
//               fontSize: 14,
//             ),
//           ),
//           SizedBox(height: 10),
//           Text(
//             value,
//             style: TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//               color: textColor,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:student_app/dashboard/attendance_pie_chart.dart';
import 'package:student_app/dashboard/homework_model.dart';
import 'package:student_app/dashboard/homework_page.dart';
import 'package:student_app/dashboard/timetable_page.dart';
import 'package:student_app/login_page.dart';
import 'package:student_app/payment/fee_details_page.dart';
import 'package:student_app/payment/payment_page.dart';
import 'package:student_app/profile_page.dart';
import 'package:student_app/school_info_page.dart';
import 'package:student_app/complaint/view_complaints_page.dart';
import 'package:student_app/subjects_page.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool isLoading = true;

  String studentName = '';
  String studentPhoto = '';
  String schoolName = '';
  String studentClass = '';
  String studentSection = '';

  int dues = 0;
  int payments = 0;
  int subjects = 0;
  Map<String, dynamic> attendance = {};
  List<Map<String, dynamic>> homeworks = [];

  @override
  void initState() {
    super.initState();
    initData(); // load data
  }

  Future<void> initData() async {
    await loadProfileData();
    await fetchDashboardData();
    setState(() {
      isLoading = false;
    });
  }

  Future<void> loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    studentName = prefs.getString('student_name') ?? '';
    studentPhoto = prefs.getString('student_photo') ?? '';
    schoolName = prefs.getString('school_name') ?? '';
    studentClass = prefs.getString('class_name') ?? '';
    studentSection = prefs.getString('section') ?? ''; //need to chnage
  }

  Future<void> fetchDashboardData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final response = await http.post(
      Uri.parse('https://school.edusathi.in/api/student/dashboard'),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      dues = data['dues'] ?? 0;
      payments = int.tryParse(data['payments'].toString()) ?? 0;
      subjects = data['subjects'] ?? 0;
      attendance = {
        'present': data['attendances']?['present'] ?? 0,
        'absent': data['attendances']?['absent'] ?? 0,
        'leave': data['attendances']?['leave'] ?? 0,
        'half_day': data['attendances']?['half_day'] ?? 0,
        'working_days': data['attendances']?['working_days'] ?? 0,
      };
      homeworks = List<Map<String, dynamic>>.from(data['homeworks'] ?? []);
    } else {
      print('❌ Dashboard fetch failed: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: isLoading
          ? null
          : LeftSidebarMenu(
              studentName: studentName,
              schoolName: schoolName,
              studentPhoto: studentPhoto,
              studentClass: studentClass,
              studentSection: studentSection,
            ),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$schoolName',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            CircleAvatar(backgroundImage: NetworkImage(studentPhoto)),
          ],
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      DashboardCard(
                        title: 'Dues',
                        value: dues.toString(),
                        borderColor: Colors.red,
                        backgroundColor: Colors.red.shade50,
                        textColor: Colors.red,
                      ),
                      DashboardCard(
                        title: 'Payments',
                        value: payments.toString(),
                        borderColor: Colors.green,
                        backgroundColor: Colors.green.shade50,
                        textColor: Colors.green,
                      ),
                      GestureDetector(
                        child: DashboardCard(
                          title: 'Subjects',
                          value: subjects.toString(),
                          borderColor: Colors.blue,
                          backgroundColor: Colors.blue.shade50,
                          textColor: Colors.blue,
                        ),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => SubjectsPage()),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Container(
                    height: 225,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.deepPurple.shade100),
                      boxShadow: [
                        BoxShadow(color: Colors.grey.shade200, blurRadius: 6),
                      ],
                    ),
                    child: AttendancePieChart(
                      present: attendance['present'] ?? 0,
                      absent: attendance['absent'] ?? 0,
                      leave: attendance['leave'] ?? 0,
                      halfDay: attendance['half_day'] ?? 0,
                      workingDays: attendance['working_days'] ?? 0,
                    ),
                  ),
                  const SizedBox(height: 10),
                  buildRecentHomeworks(context, homeworks),
                ],
              ),
            ),
    );
  }
}

class DashboardCard extends StatelessWidget {
  final String title;
  final String value;
  final Color borderColor;
  final Color backgroundColor;
  final Color textColor;

  const DashboardCard({
    super.key,
    required this.title,
    required this.value,
    required this.borderColor,
    required this.backgroundColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 98,
      height: 75,
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: borderColor, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: textColor,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

class LeftSidebarMenu extends StatelessWidget {
  final String studentName;
  final String schoolName;
  final String studentPhoto;
  final String studentClass;
  final String studentSection;

  const LeftSidebarMenu({
    super.key,
    required this.studentName,
    required this.schoolName,
    required this.studentPhoto,
    required this.studentClass,
    required this.studentSection,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Colors.deepPurple),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: studentPhoto.isNotEmpty
                      ? NetworkImage(studentPhoto)
                      : const AssetImage('') as ImageProvider,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ' $studentName',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Class: $studentClass |  Section: $studentSection',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      // Text(
                      //   '$schoolName',
                      //   style: const TextStyle(
                      //     color: Colors.white,
                      //     fontSize: 14,
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ProfilePage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.book),
            title: const Text('Homeworks'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => HomeworkPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text('Time-Table'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TimeTablePage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.subject),
            title: const Text('Subjects'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => SubjectsPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.report),
            title: const Text('Complaint'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ViewComplaintPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.attach_money),
            title: const Text('Fees'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => FeeDetailsPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.payment),
            title: const Text('Payment'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => PaymentPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.school),
            title: const Text('School Info'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => SchoolInfoPage()),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text("Logout"),
                  content: Text("Are you sure you want to logout?"),
                  actions: [
                    TextButton(
                      child: Text("Cancel"),
                      onPressed: () => Navigator.pop(context),
                    ),
                    TextButton(
                      child: Text("Logout"),
                      onPressed: () async {
                        final prefs = await SharedPreferences.getInstance();
                        final token = prefs.getString('token') ?? '';

                        final response = await http.post(
                          Uri.parse('https://school.edusathi.in/api/logout'),
                          headers: {
                            'Authorization': 'Bearer $token',
                            'Accept': 'application/json',
                          },
                        );

                        print("🔐 Logout API Response: ${response.body}");

                        if (response.statusCode == 200) {
                          final data = jsonDecode(response.body);

                          if (data['status'] == true ||
                              data['message'] == 'Logged out') {
                            await prefs.clear();

                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (_) => LoginPage()),
                              (route) => false,
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Logout failed: ${data['message']}",
                                ),
                              ),
                            );
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Logout failed. Please try again."),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
