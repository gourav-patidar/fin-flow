import 'package:flutter/material.dart';

import '../../features/dashboard/presentation/widgets/bottom_nav.dart';

/// Temporary route shell that gives the unimplemented tabs the same
/// BottomNav as the real Dashboard, so the four tabs feel connected even
/// before each screen is built. Replaced phase-by-phase.
class PlaceholderWithNav extends StatelessWidget {
  const PlaceholderWithNav({required this.routeName, super.key});

  final String routeName;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      Icons.construction_rounded,
                      size: 40,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.35),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      routeName,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Coming soon in a later phase',
                      style: TextStyle(
                        fontSize: 13,
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.55),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const BottomNav(),
          ],
        ),
      ),
    );
  }
}
