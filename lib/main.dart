import 'package:flutter/material.dart';
import 'screens/auth/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Emergency Assist",
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: LoginScreen(), // Correct: cannot use const here
    );
  }
}
