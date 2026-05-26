/// Canonical route paths. Always reference these from `context.go(...)` —
/// never hard-code path strings inside widgets.
class Routes {
  const Routes._();

  static const String onboarding = '/onboarding';
  static const String signIn = '/signin';
  static const String home = '/home';
  static const String transactions = '/transactions';
  static const String analytics = '/analytics';
  static const String profile = '/profile';

  /// Temporary developer route — remove before shipping. See Phase 1 spec.
  static const String widgetKit = '/kit';
}
