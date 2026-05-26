import 'auth_exception.dart';

/// Converts an [AuthException] into a user-facing message. The BLoC layer
/// hands the result straight to the UI; UI never imports auth_exception.
class AuthErrorMapper {
  const AuthErrorMapper._();

  static String map(AuthException e) {
    return switch (e) {
      InvalidCredentials() => 'Wrong email or password',
      UserNotFound() => 'No account found for that email',
      NetworkError() => 'Network error. Please try again.',
      UnknownAuthError(:final String message) => message,
    };
  }
}
