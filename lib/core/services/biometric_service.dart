import 'package:flutter/services.dart';

/// Wraps native biometric APIs via a hand-rolled MethodChannel.
///
/// * **iOS** uses `LAContext` from the `LocalAuthentication` framework with
///   policy `.deviceOwnerAuthenticationWithBiometrics`.
/// * **Android** uses `BiometricPrompt` from `androidx.biometric`. The host
///   `MainActivity` must extend `FragmentActivity` (BiometricPrompt
///   requirement).
///
/// The portfolio anchor of FinFlow — we intentionally do NOT use the
/// `local_auth` package as the primary path; it's only kept in pubspec as a
/// fallback reference. The runtime path goes through this channel.
class BiometricService {
  BiometricService({MethodChannel? channel})
      : _channel = channel ?? const MethodChannel(channelName);

  static const String channelName = 'com.finflow/biometric';
  final MethodChannel _channel;

  /// Whether the device has biometric hardware AND it's currently usable.
  /// Returns `false` if no sensor, no enrollment, or hardware unavailable.
  Future<bool> isAvailable() async {
    try {
      final bool? r = await _channel.invokeMethod<bool>('isAvailable');
      return r ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  /// Returns the enrolled biometric types. Useful for swapping the UI icon
  /// between "Use Face ID" and "Use fingerprint".
  Future<List<BiometricType>> getEnrolledBiometrics() async {
    try {
      final List<dynamic>? raw =
          await _channel.invokeMethod<List<dynamic>>('getEnrolledBiometrics');
      if (raw == null) return const <BiometricType>[];
      return raw
          .cast<String>()
          .map(BiometricType.fromCode)
          .where((BiometricType t) => t != BiometricType.none)
          .toList();
    } on PlatformException {
      return const <BiometricType>[];
    } on MissingPluginException {
      return const <BiometricType>[];
    }
  }

  /// Prompts the OS biometric sheet with [reason]. Never throws — every
  /// outcome maps to a [BiometricAuthResult] variant so callers don't need
  /// try/catch.
  Future<BiometricAuthResult> authenticate({required String reason}) async {
    try {
      final Map<dynamic, dynamic>? raw =
          await _channel.invokeMethod<Map<dynamic, dynamic>>(
        'authenticate',
        <String, Object?>{'reason': reason},
      );
      if (raw == null) {
        return const BiometricFailed('Empty response from platform');
      }
      final String status = raw['status'] as String? ?? 'failed';
      switch (status) {
        case 'success':
          return const BiometricSuccess();
        case 'userCancelled':
          return const BiometricUserCancelled();
        case 'notEnrolled':
          return const BiometricNotEnrolled();
        case 'lockedOut':
          return const BiometricLockedOut();
        case 'failed':
        default:
          return BiometricFailed(raw['message'] as String? ?? 'Auth failed');
      }
    } on PlatformException catch (e) {
      return BiometricFailed(e.message ?? e.code);
    } on MissingPluginException {
      // Channel not wired (e.g. running in tests without the native side).
      return const BiometricFailed('Biometric channel not available');
    }
  }
}

/// Enrolled biometric kinds. Matches what each platform reports.
enum BiometricType {
  face,
  fingerprint,
  iris,
  none;

  static BiometricType fromCode(String code) {
    return switch (code) {
      'face' => BiometricType.face,
      'fingerprint' => BiometricType.fingerprint,
      'iris' => BiometricType.iris,
      _ => BiometricType.none,
    };
  }
}

/// Sealed result returned by [BiometricService.authenticate]. No raw
/// exceptions cross this boundary.
sealed class BiometricAuthResult {
  const BiometricAuthResult();
}

class BiometricSuccess extends BiometricAuthResult {
  const BiometricSuccess();
}

class BiometricUserCancelled extends BiometricAuthResult {
  const BiometricUserCancelled();
}

class BiometricNotEnrolled extends BiometricAuthResult {
  const BiometricNotEnrolled();
}

class BiometricLockedOut extends BiometricAuthResult {
  const BiometricLockedOut();
}

class BiometricFailed extends BiometricAuthResult {
  const BiometricFailed(this.message);
  final String message;
}
