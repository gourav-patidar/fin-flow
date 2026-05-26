import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/spacing.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/secondary_button.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_event.dart';
import '../../auth/bloc/auth_state.dart';

/// Temporary post-sign-in landing screen. Confirms the auth flow works and
/// gives us a sign-out action until Phase 6 replaces it with the real
/// Dashboard.
class HomePlaceholderScreen extends StatelessWidget {
  const HomePlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Spacing.s20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              BlocBuilder<AuthBloc, AuthState>(
                builder: (BuildContext context, AuthState state) {
                  if (state is AuthAuthenticated) {
                    return GlassCard(
                      variant: GlassCardVariant.gradient,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Signed in as',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.6),
                              letterSpacing: 0.4,
                            ),
                          ),
                          const SizedBox(height: Spacing.s8),
                          Text(
                            state.user.displayName,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.4,
                            ),
                          ),
                          const SizedBox(height: Spacing.s4),
                          Text(
                            state.user.email,
                            style: TextStyle(
                              fontSize: 13,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              const Spacer(),
              SecondaryButton(
                label: 'Sign out',
                icon: const Icon(Icons.logout_rounded),
                onPressed: () => context
                    .read<AuthBloc>()
                    .add(const AuthSignOutRequested()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
