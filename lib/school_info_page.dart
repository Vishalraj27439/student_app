import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SchoolInfoPage extends StatefulWidget {
  @override
  State<SchoolInfoPage> createState() => _SchoolInfoPageState();
}

class _SchoolInfoPageState extends State<SchoolInfoPage> {
  String schoolName = "My School";
  String schoolLogo = "";
  Map<String, String> schoolDetails = {};
  bool isloading = true;

  @override
  void initState() {
    super.initState();
    fetchSchoolInfo();
  }

  Future<void> fetchSchoolInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final response = await http.post(
      Uri.parse('https://school.edusathi.in/api/school'),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      setState(() {
        schoolLogo = data['SchoolLogo'] ?? '';
        schoolDetails = {
          "Email": data['SchEmail'] ?? '',
          "Website": data['Website'] ?? '',
          "Address": data['Address'] ?? '',
          "Principal": data["PrincipalName"] ?? '',
          "Contact": data["ContactNo"].toString(),
        };
        isloading = false;
      });
    } else {
      print("❌ School info fetch failed: ${response.statusCode}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          " School Information",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
        leading: BackButton(),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.deepPurple[50],
      body: isloading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Card(
                margin: EdgeInsets.all(16),
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Logo & Name
                      Column(
                        children: [
                          schoolLogo.isNotEmpty
                              ? Image.network(schoolLogo, height: 100)
                              : Image.asset(
                                  "assets/images/logo.png",
                                  height: 100,
                                ),
                          SizedBox(height: 10),
                          Text(
                            schoolName,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),

                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          border: Border(
                            left: BorderSide(color: Colors.blue, width: 4),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text(
                            "School Details",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),

                      ...schoolDetails.entries.map(
                        (entry) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 3,
                                child: Text(
                                  entry.key,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Expanded(flex: 5, child: Text(entry.value)),
                            ],
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
}
