import '../models/user_model.dart';

class AuthService {
  // Simulate registered users
  static final List<UserModel> _registeredUsers = [];

  // Register a new user
  static void registerUser(String email, String password) {
    _registeredUsers.add(UserModel(id: email, name: password, email: email));
  }

  // Login check
  static bool loginUser(String email, String password) {
    return _registeredUsers.any(
      (user) => user.id == email && user.name == password,
    );
  }
}
