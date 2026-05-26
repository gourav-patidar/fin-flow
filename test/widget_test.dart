import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:finflow/core/routing/app_router.dart';
import 'package:finflow/core/services/biometric_service.dart';
import 'package:finflow/core/theme/app_theme.dart';
import 'package:finflow/features/auth/bloc/auth_bloc.dart';
import 'package:finflow/features/auth/bloc/auth_event.dart';
import 'package:finflow/features/auth/data/auth_local_store.dart';
import 'package:finflow/features/auth/data/mock_auth_repository.dart';
import 'package:finflow/features/onboarding/data/onboarding_preferences.dart';

Directory? _hiveDir;

/// Builds an in-memory app harness with mock preferences + mock auth + Hive
/// in a temp dir.
Future<({AuthBloc bloc, MockAuthRepository repo, Widget app})>
    _buildHarness() async {
  // Stop google_fonts from trying to hit the network in tests — it hangs
  // pumpAndSettle indefinitely when offline.
  GoogleFonts.config.allowRuntimeFetching = false;

  // Hive needs an on-disk path; use a per-test temp dir.
  _hiveDir ??= await Directory.systemTemp.createTemp('finflow_hive_test_');
  Hive.init(_hiveDir!.path);
  AuthLocalStore.resetForTesting();
  await AuthLocalStore.init();

  SharedPreferences.setMockInitialValues(<String, Object>{});
  OnboardingPreferences.resetForTesting();
  await OnboardingPreferences.init();
  final MockAuthRepository repo = MockAuthRepository();
  await repo.init();
  final AuthBloc bloc = AuthBloc(
    repository: repo,
    biometricService: BiometricService(),
  );
  bloc.add(const AuthStarted());
  await Future<void>.delayed(Duration.zero);
  await Future<void>.delayed(Duration.zero);

  final Widget app = BlocProvider<AuthBloc>.value(
    value: bloc,
    child: MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.light,
      routerConfig: AppRouter.build(bloc),
    ),
  );

  return (bloc: bloc, repo: repo, app: app);
}

void main() {
  tearDown(() async {
    await Hive.deleteFromDisk();
    AuthLocalStore.resetForTesting();
  });

  testWidgets('Fresh launch shows the onboarding brand mark',
      (WidgetTester tester) async {
    final h = await _buildHarness();
    await tester.pumpWidget(h.app);
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.text('FinFlow'), findsOneWidget);
    expect(find.text('TRACK'), findsOneWidget);
  });

  testWidgets('Skip onboarding routes to the Sign In welcome',
      (WidgetTester tester) async {
    final h = await _buildHarness();
    await tester.pumpWidget(h.app);
    await tester.pump(const Duration(milliseconds: 350));

    await tester.tap(find.text('Skip'));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Welcome back'), findsOneWidget);
  });
}
