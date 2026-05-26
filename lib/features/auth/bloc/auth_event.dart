import 'package:equatable/equatable.dart';

import '../../../shared/models/app_user.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => <Object?>[];
}

/// Fired once on cold start so the BLoC can hydrate from cached state.
class AuthStarted extends AuthEvent {
  const AuthStarted();
}

class AuthEmailSignInRequested extends AuthEvent {
  const AuthEmailSignInRequested({required this.email, required this.password});
  final String email;
  final String password;

  @override
  List<Object?> get props => <Object?>[email, password];
}

class AuthGoogleSignInRequested extends AuthEvent {
  const AuthGoogleSignInRequested();
}

class AuthBiometricRequested extends AuthEvent {
  const AuthBiometricRequested();
}

class AuthSignOutRequested extends AuthEvent {
  const AuthSignOutRequested();
}

/// Internal event — repository emitted a new auth state. Not for UI to send.
class AuthUserChanged extends AuthEvent {
  const AuthUserChanged(this.user);
  final AppUser? user;

  @override
  List<Object?> get props => <Object?>[user];
}
