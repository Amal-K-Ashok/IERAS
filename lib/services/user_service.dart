import '../models/user_model.dart';

class UserService {
  static UserModel? _currentUser;

  static void saveUser(UserModel user) {
    _currentUser = user;
  }

  static UserModel? getUser() {
    return _currentUser;
  }

  static void clearUser() {
    _currentUser = null;
  }
}
