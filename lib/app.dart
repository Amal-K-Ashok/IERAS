import 'package:flutter/material.dart';
import 'screens/auth/login_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key}); // <- add const constructor

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Intelligent Response & Emergency App',
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}
