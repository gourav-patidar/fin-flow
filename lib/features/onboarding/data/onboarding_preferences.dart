import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists whether the user has completed onboarding. Initialised once at
/// app startup so the router can decide between `/onboarding` and `/signin`
/// without an async read on every navigation.
class OnboardingPreferences {
  OnboardingPreferences._(this._prefs);

  final SharedPreferences _prefs;

  static const String _key = 'onboarding_seen_v1';
  static OnboardingPreferences? _instance;

  static OnboardingPreferences get instance {
    final OnboardingPreferences? i = _instance;
    if (i == null) {
      throw StateError(
        'OnboardingPreferences.init() must be awaited before access.',
      );
    }
    return i;
  }

  static Future<void> init() async {
    if (_instance != null) return;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _instance = OnboardingPreferences._(prefs);
  }

  bool get seen => _prefs.getBool(_key) ?? false;

  Future<void> markSeen() => _prefs.setBool(_key, true);

  @visibleForTesting
  static void resetForTesting() {
    _instance = null;
  }
}
