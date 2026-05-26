import '../../../shared/models/app_user.dart';

/// The auth contract every implementation must honor. Firebase's plug-in
/// (Phase 12) will fulfil this same interface, so swapping is a one-file
/// change in DI wiring — the BLoC and UI never see the implementation.
abstract class AuthRepository {
  /// Emits the current signed-in user, or null when signed out.
  Stream<AppUser?> get authStateChanges;

  AppUser? get currentUser;

  /// Throws [AuthException] subtype on failure.
  Future<AppUser> signInWithEmail(String email, String password);

  Future<AppUser> signInWithGoogle();

  Future<void> signOut();
}
