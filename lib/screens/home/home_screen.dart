import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../accident/accident_report_screen.dart';
import '../home/history_screen.dart';
import '../home/profile_screen.dart';
import '../tracking/tracking_screen.dart';
import '../home/map_screen.dart';
import '../../widgets/app_drawer.dart';

class HomeScreen extends StatefulWidget {
  final String userId; // UUID

  const HomeScreen({
    super.key,
    required this.userId,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;
  String? latestAccidentId;
  int? currentStatus;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchLatestAccident();
  }

  Future<void> fetchLatestAccident() async {
    final supabase = Supabase.instance.client;

    try {
      final response = await supabase
          .from('accidents')
          .select('id, status')
          .eq('camera_id', widget.userId)
          .order('timestamp', ascending: false)
          .limit(1);

      if (response.isNotEmpty) {
        latestAccidentId = response[0]['id'];
        currentStatus = response[0]['status'];
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching accident: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final List<Widget> screens = [
      HomeTab(userId: widget.userId),

      /// MAP TAB
      latestAccidentId != null
          ? MapScreen(
              accidentId: latestAccidentId!,
            )
          : const NoAccidentScreen(),

      /// TRACKING TAB
      latestAccidentId != null
          ? TrackingScreen(
              accidentId: latestAccidentId!,
            )
          : const NoAccidentScreen(),

      HistoryScreen(userId: widget.userId),

      /// ✅ FIXED PROFILE TAB
      ProfileScreen(userId: widget.userId),
    ];

    return Scaffold(
      drawer: AppDrawer(userId: widget.userId),
      body: screens[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: "Map",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_hospital),
            label: "Tracking",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: "History",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}

class HomeTab extends StatelessWidget {
  final String userId;

  const HomeTab({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 138, 208, 240),
              Color.fromARGB(255, 25, 50, 92)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Emergency SOS",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: Text(
                "Press the button below to report an accident immediately.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
            ),
            const SizedBox(height: 50),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40),
                ),
                elevation: 8,
              ),
              icon: const Icon(Icons.warning,
                  size: 28, color: Colors.white),
              label: const Text(
                "SOS - Report Accident",
                style: TextStyle(
                    fontSize: 22, color: Colors.white),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AccidentReportScreen(
                      userId: userId,
                    ),
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

class NoAccidentScreen extends StatelessWidget {
  const NoAccidentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        "No active accident found",
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}