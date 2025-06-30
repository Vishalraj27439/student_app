import 'dart:convert';
import 'package:flutter/material.dart';
import 'api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String studentName = "";
  String rollNo = "";
  String className = "";
  String section = "A";
  String contact = "";
  String address = "Not Provided";
  String fatherName = "";
  String motherName = "";
  String dob = "";
  String bloodGroup = "";
  String aadhaar = "-";
  String studentPhoto = "";

  @override
  void initState() {
    super.initState();
    loadLocalData();
    fetchProfileFromApi();
  }

  Future<void> loadLocalData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      studentName = prefs.getString('student_name') ?? '';
      className = prefs.getString('class_name') ?? '';
      studentPhoto = prefs.getString('student_photo') ?? '';
    });
  }

  Future<void> fetchProfileFromApi() async {
    try {
      final response = await ApiService.post('/student/profile');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final prefs = await SharedPreferences.getInstance();
        // Save data for future access
        await prefs.setString('roll_no', data['RollNo'].toString());
        await prefs.setString('mobile_no', data['MobileNo'].toString());
        await prefs.setString('father_name', data['FatherName'] ?? '');
        await prefs.setString('mother_name', data['MotherName'] ?? '');
        await prefs.setString('dob', data['DOB'] ?? '');
        await prefs.setString('blood_group', data['BloodGroup'] ?? '');
        await prefs.setString('aadhaar', data['LedgerNo'] ?? '');

        // Update UI
        setState(() {
          rollNo = data['RollNo'].toString();
          contact = data['MobileNo'].toString();
          fatherName = data['FatherName'] ?? '';
          motherName = data['MotherName'] ?? '';
          dob = data['DOB'] ?? '';
          bloodGroup = data['BloodGroup'] ?? '';
          aadhaar = data['LedgerNo'] ?? '';
        });
      } else {
        print('❌ Profile fetch failed: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching profile: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Student Profile", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 45,
                      backgroundImage: NetworkImage(
                        studentPhoto.isNotEmpty
                            ? studentPhoto
                            : 'https://via.placeholder.com/150',
                      ),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            studentName,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text("Roll No: $rollNo"),
                          Text("Class: $className - $section"),
                        ],
                      ),
                    ),
                  ],
                ),
                Divider(height: 30, thickness: 1),
                buildInfoRow(Icons.phone, "Contact", contact),
                buildInfoRow(
                  Icons.class_,
                  "Class & Section",
                  "$className - $section",
                ),
                buildInfoRow(Icons.location_on, "Address", address),
                buildInfoRow(
                  Icons.people,
                  "Parents",
                  "$fatherName & $motherName",
                ),
                buildInfoRow(Icons.calendar_today, "DOB", dob),
                buildInfoRow(Icons.water_drop, "Blood Group", bloodGroup),
                buildInfoRow(Icons.credit_card, "Aadhaar", aadhaar),
                SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Navigate to change password
                  },
                  icon: Icon(Icons.lock, color: Colors.white),
                  label: Text(
                    "Change Password",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildInfoRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.deepPurple),
          SizedBox(width: 10),
          Text("$title: ", style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}
