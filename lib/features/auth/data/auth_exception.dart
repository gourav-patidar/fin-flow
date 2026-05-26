/// Sealed exception type for the auth layer. Repository implementations
/// must convert their backend errors (FirebaseAuthException, network
/// failures, etc.) into one of these variants so the BLoC layer doesn't
/// leak provider details.
sealed class AuthException implements Exception {
  const AuthException();
}

class InvalidCredentials extends AuthException {
  const InvalidCredentials();
}

class UserNotFound extends AuthException {
  const UserNotFound();
}

class NetworkError extends AuthException {
  const NetworkError();
}

class UnknownAuthError extends AuthException {
  const UnknownAuthError(this.message);
  final String message;
}
