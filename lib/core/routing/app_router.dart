import 'package:go_router/go_router.dart';

import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/auth/bloc/auth_state.dart';
import '../../features/auth/presentation/sign_in_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/onboarding/data/onboarding_preferences.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/analytics/presentation/analytics_screen.dart';
import '../../features/transactions/presentation/transactions_screen.dart';
import 'go_router_refresh_stream.dart';
import 'placeholder_with_nav.dart';
import 'route_names.dart';
import 'widget_kit_screen.dart';

/// Root GoRouter for FinFlow. Built once with the [AuthBloc] so redirects
/// can react to sign-in / sign-out without rebuilding the router.
class AppRouter {
  const AppRouter._();

  static GoRouter build(AuthBloc authBloc) {
    final bool onboardingSeen = OnboardingPreferences.instance.seen;
    final bool isAuthed = authBloc.state is AuthAuthenticated;

    String initialLocation;
    if (!onboardingSeen) {
      initialLocation = Routes.onboarding;
    } else if (isAuthed) {
      initialLocation = Routes.home;
    } else {
      initialLocation = Routes.signIn;
    }

    return GoRouter(
      initialLocation: initialLocation,
      refreshListenable: GoRouterRefreshStream(authBloc.stream),
      redirect: (_, GoRouterState state) {
        final AuthState authState = authBloc.state;
        final String loc = state.matchedLocation;

        // Onboarding is its own flow — never redirect away from it.
        if (loc == Routes.onboarding) return null;
        // Dev-only kit route — never redirect.
        if (loc == Routes.widgetKit) return null;

        final bool authed = authState is AuthAuthenticated;
        final bool atSignIn = loc == Routes.signIn;

        if (authed && atSignIn) return Routes.home;
        if (!authed && !atSignIn) return Routes.signIn;
        return null;
      },
      routes: <RouteBase>[
        GoRoute(
          path: Routes.onboarding,
          builder: (_, _) => const OnboardingScreen(),
        ),
        GoRoute(
          path: Routes.signIn,
          builder: (_, _) => const SignInScreen(),
        ),
        GoRoute(
          path: Routes.home,
          builder: (_, _) => const DashboardScreen(),
        ),
        GoRoute(
          path: Routes.transactions,
          builder: (_, _) => const TransactionsScreen(),
        ),
        GoRoute(
          path: Routes.analytics,
          builder: (_, _) => const AnalyticsScreen(),
        ),
        GoRoute(
          path: Routes.profile,
          builder: (_, _) => const PlaceholderWithNav(routeName: 'Profile'),
        ),
        GoRoute(
          path: Routes.widgetKit,
          builder: (_, _) => const WidgetKitScreen(),
        ),
      ],
    );
  }
}
