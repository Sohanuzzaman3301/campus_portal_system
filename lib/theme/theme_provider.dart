import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/providers.dart';

final themeNotifierProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ThemeNotifier(prefs);
});

class ThemeNotifier extends StateNotifier<ThemeMode> {
  final SharedPreferences prefs;
  static const String _key = 'theme_mode';

  ThemeNotifier(this.prefs) : super(_getInitialThemeMode(prefs));

  static ThemeMode _getInitialThemeMode(SharedPreferences prefs) {
    final savedTheme = prefs.getString(_key);
    if (savedTheme == null) return ThemeMode.system;
    
    return ThemeMode.values.firstWhere(
      (e) => e.toString() == savedTheme,
      orElse: () => ThemeMode.system,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await prefs.setString(_key, mode.toString());
    state = mode;
  }
} 