import 'dart:io';
import 'package:flutter/foundation.dart';
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

  /// Decode image in background to reduce UI blocking
  

  /// Pick image from camera
  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80, // reduce image size for faster UI
      );

      if (!mounted || image == null) return;

      // Offload heavy work to a background isolate
      File decodedImage = await compute((path) => File(path), image.path);

      setState(() {
        pickedImage = decodedImage;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error picking image: $e")));
    }
  }

  /// Get current location
  Future<void> _getLocation() async {
    try {
      String? address = await LocationService.getCurrentLocation();

      if (!mounted) return;
      setState(() {
        locationController.text = address ?? "Unable to fetch location";
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        locationController.text = "Unable to fetch location";
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error fetching location: $e")));
    }
  }

  /// Pick date and time
  Future<void> _pickDateTime() async {
    try {
      DateTime? date = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2020),
        lastDate: DateTime.now(),
      );

      if (!mounted || date == null) return;

      TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (!mounted || time == null) return;

      final dateTime =
          DateTime(date.year, date.month, date.day, time.hour, time.minute);

      if (!mounted) return;
      setState(() {
        timeController.text = dateTime.toString();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error picking time: $e")));
    }
  }

  /// Submit report
  void _submitReport() {
    if (locationController.text.isEmpty ||
        timeController.text.isEmpty ||
        pickedImage == null) {
      if (!mounted) return;
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

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Accident Report Submitted!")),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Report Accident")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: locationController,
                    readOnly: true,
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
              readOnly: true,
              decoration: InputDecoration(
                labelText: "Time",
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: _pickDateTime,
                ),
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
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _submitReport,
                child: const Text("Submit Report"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
