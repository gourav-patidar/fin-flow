import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists the user's preferred [ThemeMode] across launches.
class ThemePreferences {
  ThemePreferences._(this._prefs);

  static const String _key = 'theme_mode';

  static ThemePreferences? _instance;
  final SharedPreferences _prefs;

  static ThemePreferences get instance {
    final ThemePreferences? i = _instance;
    if (i == null) {
      throw StateError('ThemePreferences.init() must be awaited first.');
    }
    return i;
  }

  static Future<void> init() async {
    if (_instance != null) return;
    _instance = ThemePreferences._(await SharedPreferences.getInstance());
  }

  ThemeMode get themeMode => switch (_prefs.getString(_key)) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };

  Future<void> setThemeMode(ThemeMode mode) => _prefs.setString(
        _key,
        switch (mode) {
          ThemeMode.light => 'light',
          ThemeMode.dark => 'dark',
          _ => 'system',
        },
      );
}
