import 'package:equatable/equatable.dart';

import '../../../shared/models/app_user.dart';

sealed class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => <Object?>[];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  const AuthAuthenticated(this.user);
  final AppUser user;

  @override
  List<Object?> get props => <Object?>[user];
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthFailure extends AuthState {
  const AuthFailure(this.message);
  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}
