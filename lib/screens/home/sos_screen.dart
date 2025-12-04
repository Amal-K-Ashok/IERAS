import 'package:flutter/material.dart';
import '../../widgets/app_drawer.dart';

class SosScreen extends StatelessWidget {
  const SosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SOS"),
      ),
      drawer: const AppDrawer(),
      body: const Center(
        child: Text(
          "SOS Screen",
          style: TextStyle(fontSize: 22, color: Colors.red),
        ),
      ),
    );
  }
}
