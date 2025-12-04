import 'package:flutter/material.dart';
import '../../widgets/app_drawer.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
      ),
      drawer: const AppDrawer(),
      body: const Center(
        child: Text(
          "Home Screen",
          style: TextStyle(fontSize: 22),
        ),
      ),
    );
  }
}
