import 'package:shared_preferences/shared_preferences.dart';
import 'package:testpoint/data/dummy_users.dart';
import 'package:testpoint/models/user_model.dart';

class AuthService {
  static const String _userEmailKey = 'userEmail';
  static const String _userRoleKey = 'userRole';

  Future<User?> login(String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    User? user;
    try {
      user = dummyUsers.firstWhere((u) => u.email == email);
    } catch (e) {
      // User not found
      return null;
    }

    if (user.password == password) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userEmailKey, user.email);
      await prefs.setString(_userRoleKey, user.role.toString());
      return user;
    } else {
      // Password does not match
      return null;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userEmailKey);
    await prefs.remove(_userRoleKey);
  }

  Future<User?> getCurrentUser() async {
    // Simulate network delay for session check
    await Future.delayed(const Duration(seconds: 2));

    final prefs = await SharedPreferences.getInstance();
    final userEmail = prefs.getString(_userEmailKey);
    final userRoleString = prefs.getString(_userRoleKey);

    if (userEmail != null && userRoleString != null) {
      final user = dummyUsers.firstWhere(
        (u) => u.email == userEmail,
        orElse: () => throw Exception('User not found in dummy data'),
      );
      return user;
    }
    return null;
  }
}
