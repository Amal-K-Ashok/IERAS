import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/accident_model.dart';

class AccidentService {
  static const String baseUrl =
      "https://superlunary-misael-unbickered.ngrok-free.dev";

  // 🔹 Submit accident report
  static Future<String> submitAccident({
    required String location,
    required String timestamp,
    required File image,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/accident'),
      );

      request.fields['location'] = location;
      request.fields['timestamp'] = timestamp;

      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          image.path,
        ),
      );

      final response = await request.send();

      if (response.statusCode == 200) {
        return "Accident report submitted successfully";
      } else {
        return "Failed to submit accident report";
      }
    } catch (e) {
      return "Server error";
    }
  }

  // 🔹 Fetch accident history
  static Future<List<AccidentReport>> getAccidents() async {
    final response = await http.get(Uri.parse('$baseUrl/accidents'));

    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      return data.map((e) => AccidentReport.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load accidents");
    }
  }
}
