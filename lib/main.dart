import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/routing/app_router.dart';
import 'core/services/biometric_service.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/auth/bloc/auth_event.dart';
import 'features/auth/data/auth_local_store.dart';
import 'features/auth/data/mock_auth_repository.dart';
import 'features/onboarding/data/onboarding_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await AuthLocalStore.init();
  await OnboardingPreferences.init();

  final MockAuthRepository authRepo = MockAuthRepository();
  await authRepo.init();

  final BiometricService biometricService = BiometricService();

  final AuthBloc authBloc = AuthBloc(
    repository: authRepo,
    biometricService: biometricService,
  )..add(const AuthStarted());

  final GoRouter router = AppRouter.build(authBloc);

  runApp(FinFlowApp(authBloc: authBloc, router: router));
}

class FinFlowApp extends StatelessWidget {
  const FinFlowApp({
    required this.authBloc,
    required this.router,
    super.key,
  });

  final AuthBloc authBloc;
  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthBloc>.value(
      value: authBloc,
      child: MaterialApp.router(
        title: 'FinFlow',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        routerConfig: router,
      ),
    );
  }
}
