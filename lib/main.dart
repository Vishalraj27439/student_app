import 'package:flutter/material.dart';
// import 'package:student_app/dashboard/homework_page.dart';
import 'package:student_app/splash_screen.dart';
// import 'package:student_app/payment/fees_page.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen()
    );
  }
}
