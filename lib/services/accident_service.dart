import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart';
import '../models/accident_model.dart';

class AccidentService {
  static final SupabaseClient supabase = Supabase.instance.client;

  /// ----------------------------
  /// Submit Accident
  /// ----------------------------
  static Future<String> submitAccident({
    required String userId,
    required String location,
    required double latitude,
    required double longitude,
    required String timestamp,
    required File image,
  }) async {
    try {
      /// 1️⃣ Create unique file name
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${basename(image.path)}';

      /// 2️⃣ Upload image to bucket
      await supabase.storage
          .from('accident-media') // ✅ must match your bucket name
          .upload(fileName, image);

      /// 3️⃣ Get public URL
      final imageUrl = supabase.storage
          .from('accident-media')
          .getPublicUrl(fileName);

      /// 4️⃣ Insert into accidents table
      await supabase.from('accidents').insert({
                     // ✅ Added
        'camera_id': userId,            // change if different
        'location': location,
        'latitude': latitude,
        'longitude': longitude,
                  // ✅ Added (you can make dynamic later)
        'video_url': imageUrl,          // ✅ storing image URL here
        'timestamp': timestamp,
      });

      return "Accident report submitted successfully";
    } catch (e) {
      return "Error submitting accident: $e";
    }
  }

  /// ----------------------------
  /// Get All Accidents
  /// ----------------------------
  static Future<List<AccidentReport>> getAccidents() async {
    try {
      final data = await supabase
          .from('accidents')
          .select()
          .order('timestamp', ascending: false);

      return (data as List<dynamic>)
          .map((e) => AccidentReport.fromJson(e))
          .toList();
    } catch (e) {
      print("Error fetching accidents: $e");
      return [];
    }
  }

  /// ----------------------------
  /// Get Logged In User Accidents
  /// ----------------------------
  static Future<List<AccidentReport>> getMyAccidents(String userId) async {
    try {
      final data = await supabase
          .from('accidents')
          .select()
          .eq('camera_id', userId)   // ✅ changed from camera_id
          .order('timestamp', ascending: false);

      return (data as List<dynamic>)
          .map((e) => AccidentReport.fromJson(e))
          .toList();
    } catch (e) {
      print("Error fetching user accidents: $e");
      return [];
    }
    print("History userId: $userId");

  }
  
}
