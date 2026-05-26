import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/services/biometric_service.dart';
import '../../../shared/models/app_user.dart';
import '../data/auth_error_mapper.dart';
import '../data/auth_exception.dart';
import '../data/auth_local_store.dart';
import '../data/mock_auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required MockAuthRepository repository,
    required BiometricService biometricService,
  })  : _repo = repository,
        _biometric = biometricService,
        super(const AuthInitial()) {
    on<AuthStarted>(_onStarted);
    on<AuthEmailSignInRequested>(_onEmailSignIn);
    on<AuthGoogleSignInRequested>(_onGoogleSignIn);
    on<AuthBiometricRequested>(_onBiometric);
    on<AuthSignOutRequested>(_onSignOut);
    on<AuthUserChanged>(_onUserChanged);

    _subscription = _repo.authStateChanges
        .listen((AppUser? user) => add(AuthUserChanged(user)));
  }

  final MockAuthRepository _repo;
  final BiometricService _biometric;
  late final StreamSubscription<AppUser?> _subscription;

  void _onStarted(AuthStarted event, Emitter<AuthState> emit) {
    final AppUser? user = _repo.currentUser;
    emit(user != null ? AuthAuthenticated(user) : const AuthUnauthenticated());
  }

  Future<void> _onEmailSignIn(
    AuthEmailSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await _repo.signInWithEmail(event.email, event.password);
      // AuthUserChanged from the stream will emit AuthAuthenticated.
    } on AuthException catch (e) {
      emit(AuthFailure(AuthErrorMapper.map(e)));
    }
  }

  Future<void> _onGoogleSignIn(
    AuthGoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await _repo.signInWithGoogle();
    } on AuthException catch (e) {
      emit(AuthFailure(AuthErrorMapper.map(e)));
    }
  }

  Future<void> _onBiometric(
    AuthBiometricRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final AppUser? cached = _repo.getLastUser();
    if (cached == null) {
      emit(const AuthFailure('Please sign in with your password first.'));
      return;
    }
    final String? enabledFor = AuthLocalStore.instance.biometricEnabledForUid;
    if (enabledFor == null || enabledFor != cached.id) {
      emit(const AuthFailure('Enable biometric from your profile first.'));
      return;
    }

    final bool available = await _biometric.isAvailable();
    if (!available) {
      emit(const AuthFailure('Biometric is unavailable on this device.'));
      return;
    }

    final BiometricAuthResult result =
        await _biometric.authenticate(reason: 'Unlock FinFlow');
    switch (result) {
      case BiometricSuccess():
        await _repo.signInFromCache(cached);
      case BiometricUserCancelled():
        // Silently restore the previous state; not a failure.
        final AppUser? cur = _repo.currentUser;
        emit(cur != null
            ? AuthAuthenticated(cur)
            : const AuthUnauthenticated());
      case BiometricNotEnrolled():
        emit(const AuthFailure(
          'No biometrics enrolled on this device.',
        ));
      case BiometricLockedOut():
        emit(const AuthFailure(
          'Too many attempts. Try again later or use your password.',
        ));
      case BiometricFailed(:final String message):
        emit(AuthFailure(message));
    }
  }

  Future<void> _onSignOut(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _repo.signOut();
  }

  void _onUserChanged(AuthUserChanged event, Emitter<AuthState> emit) {
    emit(event.user != null
        ? AuthAuthenticated(event.user!)
        : const AuthUnauthenticated());
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}
