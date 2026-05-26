import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Tiny Hive-backed store for auth-related flags. The only key written here
/// today is `biometric_enabled_for_uid`, used by Phase 4's biometric
/// quick-unlock to know which user the device is biometrics-bound to.
///
/// Kept as a separate store (not under [MockAuthRepository]) because these
/// flags persist across the eventual Firebase swap.
class AuthLocalStore {
  AuthLocalStore._(this._box);

  static const String _boxName = 'auth';
  static const String _biometricKey = 'biometric_enabled_for_uid';

  static AuthLocalStore? _instance;
  static AuthLocalStore get instance {
    final AuthLocalStore? i = _instance;
    if (i == null) {
      throw StateError('AuthLocalStore.init() must be awaited first.');
    }
    return i;
  }

  final Box<dynamic> _box;

  static Future<void> init() async {
    if (_instance != null) return;
    final Box<dynamic> box = await Hive.openBox<dynamic>(_boxName);
    _instance = AuthLocalStore._(box);
  }

  /// The user id biometric is bound to, or null if disabled.
  String? get biometricEnabledForUid => _box.get(_biometricKey) as String?;

  Future<void> enableBiometricFor(String uid) =>
      _box.put(_biometricKey, uid);

  Future<void> disableBiometric() => _box.delete(_biometricKey);

  @visibleForTesting
  static void resetForTesting() {
    _instance = null;
  }
}
