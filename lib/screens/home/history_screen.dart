import 'package:flutter/material.dart';
import '../../services/accident_service.dart';
import '../../models/accident_model.dart';
import 'map_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HistoryScreen extends StatelessWidget {
  final String userId;

  const HistoryScreen({super.key, required this.userId});

  // ✅ Fetch ambulance using ACCIDENT UUID
  Future<String?> _getAssignedAmbulance(String accidentId) async {
    try {
      final response = await Supabase.instance.client
          .from('accidents')
          .select('ambu_id')
          .eq('id', accidentId)   // ✅ MATCH BY UUID
          .maybeSingle();

      if (response != null && response['ambu_id'] != null) {
        return response['ambu_id'].toString();
      }
    } catch (e) {
      print("Error fetching ambulance for $accidentId: $e");
    }
    return null;
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFFF5F6FA),

    appBar: AppBar(
      title: const Text(
        "Accident History",
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      backgroundColor: const Color.fromARGB(255, 25, 50, 92),
      elevation: 0,
    ),

    body: FutureBuilder<List<AccidentReport>>(
      future: AccidentService.getMyAccidents(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              "Error: ${snapshot.error}",
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        final reports = snapshot.data ?? [];

        if (reports.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, size: 70, color: Colors.grey),
                SizedBox(height: 10),
                Text(
                  "No accident reports found",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 10),
          itemCount: reports.length,
          itemBuilder: (context, index) {
            final report = reports[index];
            final isApproved =
                report.status.toLowerCase() == "approved";

            return GestureDetector(
              onTap: () {
                if (isApproved) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          MapScreen(accidentId: report.id),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Ambulance not approved yet."),
                    ),
                  );
                }
              },
              child: Container(
                margin: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade300,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: report.photoPath.isNotEmpty
                          ? Image.network(
                              report.photoPath,
                              width: 85,
                              height: 85,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              width: 85,
                              height: 85,
                              color: Colors.grey.shade200,
                              child: const Icon(
                                Icons.image,
                                size: 40,
                                color: Colors.grey,
                              ),
                            ),
                    ),

                    const SizedBox(width: 15),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            report.location,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Time: ${report.time}",
                            style: const TextStyle(
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 10),

                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6),
                            decoration: BoxDecoration(
                              color: isApproved
                                  ? Colors.green.shade100
                                  : Colors.orange.shade100,
                              borderRadius:
                                  BorderRadius.circular(20),
                            ),
                            child: Text(
                              report.status.toUpperCase(),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isApproved
                                    ? Colors.green
                                    : Colors.orange,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Icon(Icons.arrow_forward_ios,
                        size: 16, color: Colors.grey),
                  ],
                ),
              ),
            );
          },
        );
      },
    ),
  );
}
}