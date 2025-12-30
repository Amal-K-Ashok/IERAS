import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import 'user_service.dart';

class AuthService {
  // Base URL of your FastAPI backend
  // Use localhost 10.0.2.2 for emulator or your ngrok URL for testing
  static const String baseUrl =
      "https://superlunary-misael-unbickered.ngrok-free.dev";

  /// -----------------------------
  /// REGISTER
  /// -----------------------------
  static Future<void> register({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/register');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      // Registration successful
      return;
    } else {
      final data = jsonDecode(response.body);
      throw Exception(data['detail'] ?? "Registration failed");
    }
  }

  /// -----------------------------
  /// LOGIN
  /// -----------------------------
  static Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/login');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // Create UserModel from response
      final user = UserModel(
        id: data['id'],
        name: data['name'],
        email: data['email'],
      );

      // Save user locally
      UserService.saveUser(user);

      return user;
    } else {
      final data = jsonDecode(response.body);
      throw Exception(data['detail'] ?? "Login failed");
    }
  }

  /// -----------------------------
  /// RESET PASSWORD
  /// -----------------------------
  static Future<void> resetPassword({
    required String email,
    required String oldPassword,
    required String newPassword,
  }) async {
    final url = Uri.parse('$baseUrl/reset-password');

    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'old_password': oldPassword,
        'new_password': newPassword,
      }),
    );

    if (response.statusCode != 200) {
      final data = jsonDecode(response.body);
      throw Exception(data['detail'] ?? "Failed to reset password");
    }
  }

  /// -----------------------------
  /// LOGOUT (CLEAR USER)
  /// -----------------------------
  static void logout() {
    UserService.clearUser();
  }
}
