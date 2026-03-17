import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/accident_service.dart';
import '../../services/location_service.dart';

class AccidentReportScreen extends StatefulWidget {
  final String userId;

  const AccidentReportScreen({
    super.key,
    required this.userId,
  });

  @override
  State<AccidentReportScreen> createState() =>
      _AccidentReportScreenState();
}

class _AccidentReportScreenState extends State<AccidentReportScreen> {
  final TextEditingController locationController = TextEditingController();
  final TextEditingController timeController = TextEditingController();

  File? pickedImage;
  bool isSubmitting = false;

  double? latitude;
  double? longitude;

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

  Future<void> _getLocation() async {
    final locationData = await LocationService.getCurrentLocation();

    if (locationData != null) {
      setState(() {
        locationController.text = locationData['address'];
        latitude = locationData['latitude'];
        longitude = locationData['longitude'];
      });
    } else {
      locationController.text = "Unable to detect location";
    }
  }

  Future<void> _pickDateTime() async {
    DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (date == null) return;

    TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time == null) return;

    final dateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    setState(() {
      timeController.text = dateTime.toString();
    });
  }

  Widget buildSectionTitle(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget buildCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Future<void> _submitReport() async {
    if (locationController.text.isEmpty ||
        timeController.text.isEmpty ||
        pickedImage == null ||
        latitude == null ||
        longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please complete all fields")),
      );
      return;
    }

    setState(() => isSubmitting = true);

    final result = await AccidentService.submitAccident(
      userId: widget.userId,
      location: locationController.text,
      latitude: latitude!,
      longitude: longitude!,
      timestamp: timeController.text,
      image: pickedImage!,
    );

    setState(() => isSubmitting = false);

    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(result)));

    if (result.contains("success")) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3EEFF),
      appBar: AppBar(
        title: const Text("Report Accident"),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 143, 82, 255),
                Color.fromARGB(255, 90, 60, 255),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            // LOCATION
            buildSectionTitle("Accident Location"),
            buildCard(
              child: ListTile(
                leading: const Icon(Icons.location_on, color: Colors.deepPurple),
                title: TextField(
                  controller: locationController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    hintText: "Detect location",
                    border: InputBorder.none,
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.my_location),
                  onPressed: _getLocation,
                ),
              ),
            ),

            const SizedBox(height: 25),

            // TIME
            buildSectionTitle("Accident Time"),
            buildCard(
              child: ListTile(
                leading: const Icon(Icons.access_time, color: Colors.deepPurple),
                title: TextField(
                  controller: timeController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    hintText: "Select date & time",
                    border: InputBorder.none,
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: _pickDateTime,
                ),
              ),
            ),

            const SizedBox(height: 25),

            // IMAGE SECTION
            buildSectionTitle("Upload Evidence"),
            Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.grey.shade200,
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: pickedImage == null
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt,
                              size: 50, color: Colors.grey),
                          SizedBox(height: 10),
                          Text("No image selected",
                              style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.file(
                        pickedImage!,
                        fit: BoxFit.cover,
                      ),
                    ),
            ),

            const SizedBox(height: 15),

            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.camera_alt),
              label: const Text("Capture Photo"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                    horizontal: 25, vertical: 12),
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // SUBMIT BUTTON
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: isSubmitting ? null : _submitReport,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: isSubmitting
                    ? const CircularProgressIndicator(
                        color: Colors.white)
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