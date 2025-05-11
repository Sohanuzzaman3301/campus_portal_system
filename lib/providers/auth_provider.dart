import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../models/user.dart';
import '../database/user_database_helper.dart';

// Service provider
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

// Auth state notifier provider
final authNotifierProvider = StateNotifierProvider<AuthNotifier, User?>((ref) {
  final authService = ref.read(authServiceProvider);
  return AuthNotifier(authService);
});

class AuthNotifier extends StateNotifier<User?> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(null) {
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final isLoggedIn = await _authService.isLoggedIn();
    if (isLoggedIn) {
      state = await _authService.getCurrentUser();
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      final user = await _authService.login(email, password);
      if (user != null) {
        state = user;
        return true;
      }
      return false;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    state = null;
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      final success = await UserDatabaseHelper.instance.insertUser({
        'name': name,
        'email': email,
        'password': password,
        'role': role,
        'is_verified': 0,
      });
      
      if (success > 0) {
        return await login(email, password);
      }
      return false;
    } catch (e) {
      print('Registration error: $e');
      return false;
    }
  }
}
