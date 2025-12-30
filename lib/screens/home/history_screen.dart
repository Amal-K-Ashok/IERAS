import 'package:flutter/material.dart';
import '../../services/accident_service.dart';
import '../../models/accident_model.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Accident History"),
        backgroundColor: Colors.redAccent,
      ),
      body: FutureBuilder<List<AccidentReport>>(
        future: AccidentService.getAccidents(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "No accident reports found",
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          final reports = snapshot.data!;

          return ListView.builder(
            itemCount: reports.length,
            itemBuilder: (context, index) {
              final report = reports[index];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),

                  // ✅ IMAGE FROM SERVER
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: report.photoPath.isNotEmpty
                        ? Image.network(
                            '${AccidentService.baseUrl}/${report.photoPath}',
                            width: 70,
                            height: 70,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 70,
                                height: 70,
                                color: Colors.grey,
                                child: const Icon(
                                  Icons.broken_image,
                                  color: Colors.white,
                                ),
                              );
                            },
                          )
                        : Container(
                            width: 70,
                            height: 70,
                            color: Colors.grey,
                            child: const Icon(
                              Icons.image,
                              color: Colors.white,
                            ),
                          ),
                  ),

                  // ✅ TEXT DETAILS
                  title: Text(
                    report.location,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text("Time: ${report.time}"),
                      const SizedBox(height: 2),
                      Text(
                        "Status: ${report.status}",
                        style: const TextStyle(
                          color: Colors.blueGrey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
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
