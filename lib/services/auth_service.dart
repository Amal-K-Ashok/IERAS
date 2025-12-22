import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // REGISTER
  static Future<void> register({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? "Registration failed");
    }
  }

  // LOGIN
  static Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? "Login failed");
    }
  }

  // LOGOUT
  static Future<void> logout() async {
    await _auth.signOut();
  }

  // CHECK LOGIN STATUS
  static bool isLoggedIn() {
    return _auth.currentUser != null;
  }
}
