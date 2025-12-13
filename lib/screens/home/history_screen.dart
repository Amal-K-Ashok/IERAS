import 'dart:io';
import 'package:flutter/material.dart';
import '../../services/accident_service.dart';
import '../../models/accident_model.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get all stored accident reports
    List<AccidentReport> reports = AccidentService.getAccidents();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Accident History"),
      ),

      body: reports.isEmpty
          ? const Center(
              child: Text(
                "No accident reports found",
                style: TextStyle(fontSize: 18),
              ),
            )

          : ListView.builder(
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

                    // IMAGE
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(report.photoPath),
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                      ),
                    ),

                    // TEXT
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
            ),
    );
  }
}
