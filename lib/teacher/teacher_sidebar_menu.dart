import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:student_app/login_page.dart';
import 'package:student_app/payment/payment_page.dart';
import 'package:student_app/school_info_page.dart';
import 'package:student_app/teacher/teacher_attendance_screen.dart';
import 'package:student_app/teacher/teacher_homework_page.dart';
import 'package:student_app/teacher/teacher_profile_page.dart';
import 'package:student_app/dashboard/attendance_screen.dart';
import 'package:student_app/dashboard/timetable_page.dart';
import 'package:student_app/complaint/view_complaints_page.dart';

class TeacherSidebarMenu extends StatefulWidget {
  const TeacherSidebarMenu({super.key});

  @override
  State<TeacherSidebarMenu> createState() => _TeacherSidebarMenuState();
}

class _TeacherSidebarMenuState extends State<TeacherSidebarMenu> {
  String teacherName = '';
  String teacherPhoto = '';
  String teacherClass = '';
  String teacherSection = '';

  @override
  void initState() {
    super.initState();
    loadTeacherInfo();
  }

  Future<void> loadTeacherInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      teacherName = prefs.getString('teacher_name') ?? 'name';
      teacherPhoto = prefs.getString('teacher_photo') ?? 'photo';
      teacherClass = prefs.getString('teacher_class') ?? 'class';
      teacherSection = prefs.getString('teacher_section') ?? 'section';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          Container(
            color: Colors.deepPurple,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            height: 130,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundImage: teacherPhoto.isNotEmpty
                      ? NetworkImage(
                          teacherPhoto.startsWith('http')
                              ? teacherPhoto
                              : 'https://school.edusathi.in/$teacherPhoto',
                        )
                      : const AssetImage('assets/images/logo.png')
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
                        teacherName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Class Teacher',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      Text(
                        '$teacherClass - $teacherSection',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          sidebarItem(context, Icons.dashboard, 'Dashboard', () {
            Navigator.pop(context);
          }),

          sidebarItem(context, Icons.person, 'Profile', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TeacherProfilePage()),
            );
          }),

          sidebarItem(context, Icons.book, 'Homeworks', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => TeacherHomeworkPage()),
            );
          }),

          sidebarItem(context, Icons.calendar_month, 'Student Attendance', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AttendanceScreen()),
            );
          }),

          sidebarItem(context, Icons.schedule, 'Timetable', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TimeTablePage()),
            );
          }),

          sidebarItem(context, Icons.report, 'Complaint', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ViewComplaintPage()),
            );
          }),

          sidebarItem(context, Icons.payment, 'Payments', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PaymentPage()),
            );
          }),
          sidebarItem(context, Icons.calendar_month, 'My Attendance', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => TeacherAttendanceScreen()),
            );
          }),

          sidebarItem(context, Icons.school, 'School Info', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => SchoolInfoPage()),
            );
          }),
          Divider(),

          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Logout"),
                  content: const Text("Are you sure you want to logout?"),
                  actions: [
                    TextButton(
                      child: const Text("Cancel"),
                      onPressed: () => Navigator.pop(context),
                    ),
                    TextButton(
                      child: const Text("Logout"),
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

  ListTile sidebarItem(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    return ListTile(leading: Icon(icon), title: Text(title), onTap: onTap);
  }
}
