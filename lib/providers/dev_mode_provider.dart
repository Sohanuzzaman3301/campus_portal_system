import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final devModeProvider = StateNotifierProvider<DevModeNotifier, bool>((ref) {
  return DevModeNotifier();
});

class DevModeNotifier extends StateNotifier<bool> {
  DevModeNotifier() : super(false) {
    _loadDevMode();
  }

  static const _key = 'dev_mode';

  Future<void> _loadDevMode() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_key) ?? false;
  }

  Future<void> toggleDevMode() async {
    final prefs = await SharedPreferences.getInstance();
    state = !state;
    await prefs.setBool(_key, state);
  }
} 