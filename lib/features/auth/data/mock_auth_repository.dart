import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../shared/models/app_user.dart';
import 'auth_exception.dart';
import 'auth_repository.dart';

/// Mock implementation for development. Swap to FirebaseAuthRepository when
/// Firebase is configured.
///
/// Behaviour:
///  * Any email with password length ≥ 6 succeeds, returning an [AppUser]
///    whose `displayName` is the email's local-part.
///  * The literal email `fail@test.com` throws [InvalidCredentials] so we
///    can exercise the error UI without Firebase.
///  * Signed-in user is persisted to [SharedPreferences] so auth survives
///    cold restart, matching what real Firebase would give us.
///  * A second key (`auth.last_user_v1`) persists the user even across
///    sign-out so the biometric quick-unlock flow (Phase 4) can resume the
///    session without a password.
class MockAuthRepository implements AuthRepository {
  MockAuthRepository();

  static const String _currentUserKey = 'auth.current_user_v1';
  static const String _lastUserKey = 'auth.last_user_v1';
  static const String _failEmail = 'fail@test.com';

  final StreamController<AppUser?> _controller =
      StreamController<AppUser?>.broadcast();
  AppUser? _currentUser;
  SharedPreferences? _prefs;
  bool _initialized = false;

  /// Loads any persisted user. Must be awaited before reading [currentUser].
  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    _prefs = await SharedPreferences.getInstance();
    final String? raw = _prefs!.getString(_currentUserKey);
    if (raw != null) {
      try {
        final Map<String, dynamic> json =
            jsonDecode(raw) as Map<String, dynamic>;
        _currentUser = AppUser.fromJson(json);
      } on FormatException {
        await _prefs!.remove(_currentUserKey);
      }
    }
  }

  @override
  Stream<AppUser?> get authStateChanges => _controller.stream;

  @override
  AppUser? get currentUser => _currentUser;

  /// Last successfully signed-in user. Kept across sign-out so biometric
  /// quick-unlock has a target. Returns null if no one has ever signed in
  /// on this install.
  AppUser? getLastUser() {
    final String? raw = _prefs?.getString(_lastUserKey);
    if (raw == null) return null;
    try {
      final Map<String, dynamic> json = jsonDecode(raw) as Map<String, dynamic>;
      return AppUser.fromJson(json);
    } on FormatException {
      return null;
    }
  }

  /// Re-establishes the session as [user] without checking credentials.
  /// Intended to be called only by [AuthBloc] AFTER a successful biometric
  /// authentication.
  Future<AppUser> signInFromCache(AppUser user) async {
    await _persistAndEmit(user);
    return user;
  }

  @override
  Future<AppUser> signInWithEmail(String email, String password) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    if (email == _failEmail) {
      throw const InvalidCredentials();
    }
    if (password.length < 6) {
      throw const InvalidCredentials();
    }
    final String localPart = email.contains('@')
        ? email.substring(0, email.indexOf('@'))
        : email;
    final AppUser user = AppUser(
      id: 'mock-${email.hashCode.toUnsigned(32)}',
      email: email,
      displayName: _humanize(localPart),
    );
    await _persistAndEmit(user);
    return user;
  }

  @override
  Future<AppUser> signInWithGoogle() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    const AppUser user = AppUser(
      id: 'mock-google-aarav',
      email: 'aarav.sharma@gmail.com',
      displayName: 'Aarav Sharma',
    );
    await _persistAndEmit(user);
    return user;
  }

  @override
  Future<void> signOut() async {
    await _prefs?.remove(_currentUserKey);
    // _lastUserKey is intentionally preserved for biometric quick-unlock.
    _currentUser = null;
    _controller.add(null);
  }

  Future<void> _persistAndEmit(AppUser user) async {
    _currentUser = user;
    final String json = jsonEncode(user.toJson());
    await _prefs?.setString(_currentUserKey, json);
    await _prefs?.setString(_lastUserKey, json);
    _controller.add(user);
  }

  String _humanize(String localPart) {
    final String cleaned = localPart.replaceAll(RegExp(r'[^a-zA-Z]+'), ' ').trim();
    if (cleaned.isEmpty) return localPart;
    return cleaned
        .split(' ')
        .where((String s) => s.isNotEmpty)
        .map((String s) => s[0].toUpperCase() + s.substring(1).toLowerCase())
        .join(' ');
  }
}
