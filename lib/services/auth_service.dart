import 'package:shared_preferences/shared_preferences.dart';
import '../database/user_database_helper.dart';
import '../models/user.dart';

class AuthService {
  final UserDatabaseHelper _dbHelper = UserDatabaseHelper.instance;

  // SharedPreferences keys
  static const String _isLoggedInKey = 'isLoggedIn';
  static const String _userEmailKey = 'userEmail';

  Future<User?> login(String email, String password) async {
    try {
      final user = await _dbHelper.getUserByEmail(email);
      
      if (user != null && user.password == password) {
        // Save login state
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_isLoggedInKey, true);
        await prefs.setString(_userEmailKey, email);
        return user;
      }
      return null;
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  Future<User?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;
      final email = prefs.getString(_userEmailKey);

      if (isLoggedIn && email != null) {
        return await _dbHelper.getUserByEmail(email);
      }
      return null;
    } catch (e) {
      print('Get current user error: $e');
      return null;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      // Check if user already exists
      final existingUser = await _dbHelper.getUserByEmail(email);
      if (existingUser != null) {
        return false;
      }

      // Create new user
      final id = await _dbHelper.insertUser({
        'name': name,
        'email': email,
        'password': password,
        'role': role,
        'is_verified': 0,
      });

      return id > 0;
    } catch (e) {
      print('Registration error: $e');
      return false;
    }
  }
}
