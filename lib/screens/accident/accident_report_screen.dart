import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
  bool isSubmitting = false;

  // 📸 Capture image
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );

    if (!mounted || image == null) return;

    setState(() {
      pickedImage = File(image.path);
    });
  }

  // 📍 Auto-detect location
  Future<void> _getLocation() async {
    try {
      final address = await LocationService.getCurrentLocation();
      if (!mounted) return;

      setState(() {
        locationController.text = address ?? "Unable to detect location";
      });
    } catch (e) {
      locationController.text = "Unable to detect location";
      print("Location error: $e");
    }
  }

  // ⏰ Pick date & time
  Future<void> _pickDateTime() async {
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

    final dateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    setState(() {
      timeController.text = dateTime.toIso8601String();
    });
  }

  // 🚨 Submit to backend
  Future<void> _submitReport() async {
    if (locationController.text.trim().isEmpty ||
        timeController.text.trim().isEmpty ||
        pickedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please complete all fields")),
      );
      return;
    }

    setState(() => isSubmitting = true);

    // Submit report and get server response
    final result = await AccidentService.submitAccident(
      location: locationController.text.trim(),
      timestamp: timeController.text.trim(),
      image: pickedImage!,
    );

    setState(() => isSubmitting = false);

    if (!mounted) return;

    // Show server response
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(result)));

    if (result.toLowerCase().contains("success")) {
      // Return true to indicate refresh is needed in history screen
      Navigator.pop(context, true);
    }
  }

  @override
  void dispose() {
    locationController.dispose();
    timeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Report Accident"),
        backgroundColor: Colors.redAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 📍 Location
            Card(
              child: ListTile(
                leading: const Icon(Icons.location_on),
                title: TextField(
                  controller: locationController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: "Location",
                    border: InputBorder.none,
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.my_location),
                  onPressed: _getLocation,
                ),
              ),
            ),
            const SizedBox(height: 15),

            // ⏰ Time
            Card(
              child: ListTile(
                leading: const Icon(Icons.access_time),
                title: TextField(
                  controller: timeController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: "Time",
                    border: InputBorder.none,
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: _pickDateTime,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 📸 Image preview
            Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(15),
              ),
              child: pickedImage == null
                  ? const Center(
                      child: Text(
                        "No image selected",
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.file(
                        pickedImage!,
                        fit: BoxFit.cover,
                      ),
                    ),
            ),
            const SizedBox(height: 10),

            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.camera_alt),
              label: const Text("Capture Photo"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
            ),
            const SizedBox(height: 30),

            // 🚀 Submit
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isSubmitting ? null : _submitReport,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                ),
                child: isSubmitting
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : const Text(
                        "Submit Report",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
