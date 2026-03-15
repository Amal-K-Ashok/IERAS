import 'package:flutter/material.dart';
import '../screens/home/history_screen.dart';
import '../screens/home/profile_screen.dart';

class AppDrawer extends StatelessWidget {
  final String userId;

  const AppDrawer({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.redAccent,
            ),
            child: Text(
              "Menu",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),

          ListTile(
            leading: const Icon(Icons.history),
            title: const Text("Accident History"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => HistoryScreen(userId: userId),
                ),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.person),
            title: const Text("Profile"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProfileScreen(userId: userId), // ✅ FIXED
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}