import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:student_app/dashboard/attendance_pie_chart.dart';
import 'package:student_app/dashboard/attendance_screen.dart';
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
  String studentsection = '';

  int dues = 0;
  int payments = 0;
  int subjects = 0;
  Map<String, dynamic> attendance = {};
  List<Map<String, dynamic>> homeworks = [];

  @override
  void initState() {

    
    super.initState();
    initData();
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
    studentsection = prefs.getString('section') ?? '';
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
    prefs.getKeys().forEach((key) {
      print('$key = ${prefs.get(key)}');
      FirebaseMessaging.instance.getToken().then((fcmToken) {
  print("🟢 FCM Device Token: $fcmToken");

  
});

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: isLoading
          ? null
          : LeftSidebarMenu(
              studentName: studentName,
              studentPhoto: studentPhoto,
              studentClass: studentClass,
              studentsection: studentsection,
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
                      GestureDetector(
                        child: DashboardCard(
                          title: 'Dues',
                          value: dues.toString(),
                          borderColor: Colors.red,
                          backgroundColor: Colors.red.shade50,
                          textColor: Colors.red,
                        ),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => FeeDetailsPage()),
                        ),
                      ),
                      GestureDetector(
                        child: DashboardCard(
                          title: 'Payments',
                          value: payments.toString(),
                          borderColor: Colors.green,
                          backgroundColor: Colors.green.shade50,
                          textColor: Colors.green,
                        ),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => PaymentPage()),
                        ),
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
  // final String schoolName;
  final String studentPhoto;
  final String studentClass;
  final String studentsection;

  const LeftSidebarMenu({
    super.key,
    required this.studentName,
    // required this.schoolName,
    required this.studentPhoto,
    required this.studentClass,
    required this.studentsection,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 270,
      child: Drawer(
        child: ListView(
          children: [
            Container(
              color: Colors.deepPurple,
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ), // Reduce padding
              height: 120, // Set a smaller height (adjust as needed)
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundImage: studentPhoto.isNotEmpty
                        ? NetworkImage(studentPhoto)
                        : const AssetImage('assets/images/default_avatar.png')
                              as ImageProvider,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          studentName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          'Class: $studentClass',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          'Section: ${studentsection.isNotEmpty ? studentsection : "-"}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            sidebarTile(
              icon: Icons.dashboard,
              title: 'Dashboard',
              onTap: () => Navigator.pop(context),
            ),
            sidebarTile(
              icon: Icons.person,
              title: 'Profile',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ProfilePage()),
                );
              },
            ),

            sidebarTile(
              icon: Icons.book,
              title: 'Homeworks',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => HomeworkPage()),
                );
              },
            ),
            sidebarTile(
              icon: Icons.calendar_month,
              title: 'Attendance',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AttendanceScreen()),
                );
              },
            ),
            sidebarTile(
              icon: Icons.calendar_today,
              title: 'Time-Table',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TimeTablePage()),
                );
              },
            ),

            sidebarTile(
              icon: Icons.subject,
              title: 'Subjects',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => SubjectsPage()),
                );
              },
            ),
            sidebarTile(
              icon: Icons.report,
              title: 'Complaint',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ViewComplaintPage()),
                );
              },
            ),
            sidebarTile(
              icon: Icons.attach_money,
              title: 'Fees',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FeeDetailsPage()),
                );
              },
            ),
            sidebarTile(
              icon: Icons.payment,
              title: 'Payment',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => PaymentPage()),
                );
              },
            ),
            sidebarTile(
              icon: Icons.school,
              title: 'School Info',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => SchoolInfoPage()),
                );
              },
            ),

            // const Divider(),
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
                                content: Text(
                                  "Logout failed. Please try again.",
                                ),
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
      ),
    );
  }
}

Widget sidebarTile({
  required IconData icon,
  required String title,
  required VoidCallback onTap,
}) {
  return ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 13, vertical: 0),
    visualDensity: VisualDensity(vertical: -2),

    leading: Icon(icon),
    title: Text(title),
    onTap: onTap,
  );
}
