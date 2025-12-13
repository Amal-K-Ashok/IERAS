import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/accident_model.dart';
import '../../services/accident_service.dart';
import '../../services/location_service.dart';

class AccidentReportScreen extends StatefulWidget {
  const AccidentReportScreen({super.key});

  @override
  State<AccidentReportScreen> createState() => _AccidentReportScreenState();
}

class _AccidentReportScreenState extends State<AccidentReportScreen> {
  final TextEditingController locationController = TextEditingController();
  final TextEditingController timeController = TextEditingController();

  File? pickedImage;

  Future<void> _pickImage() async {
  final picker = ImagePicker();
  final image = await picker.pickImage(
    source: ImageSource.camera,
    imageQuality: 100, // ensures correct color format
  );

  if (image != null) {
    setState(() {
      pickedImage = File(image.path);
    });
  }
}


  Future<void> _getLocation() async {
    String? loc = await LocationService.getCurrentLocation();
    setState(() {
      locationController.text = loc ?? "Unable to fetch location";
    });
  }

  void _submitReport() {
    if (locationController.text.isEmpty ||
        timeController.text.isEmpty ||
        pickedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please complete all fields!")),
      );
      return;
    }

    AccidentReport report = AccidentReport(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      location: locationController.text,
      time: timeController.text,
      photoPath: pickedImage!.path,
      status: "Pending",
    );

    AccidentService.addAccident(report);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Accident Report Submitted!")),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Report Accident")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: locationController,
                    decoration: const InputDecoration(
                      labelText: "Location",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _getLocation,
                  child: const Text("Auto"),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: timeController,
              decoration: const InputDecoration(
                labelText: "Time",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              height: 200,
              width: double.infinity,
              color: Colors.grey.shade300,
              child: pickedImage == null
                  ? const Center(child: Text("No image selected"))
                  : Image.file(pickedImage!, fit: BoxFit.cover),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text("Capture Photo"),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _submitReport,
              child: const Text("Submit Report"),
            )
          ],
        ),
      ),
    );
  }
}
