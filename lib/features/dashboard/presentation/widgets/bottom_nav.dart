import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_names.dart';

class _NavTab {
  const _NavTab(this.label, this.icon, this.route);
  final String label;
  final IconData icon;
  final String route;
}

const List<_NavTab> _tabs = <_NavTab>[
  _NavTab('Home', Icons.home_rounded, Routes.home),
  _NavTab('Transactions', Icons.swap_horiz_rounded, Routes.transactions),
  _NavTab('Analytics', Icons.bar_chart_rounded, Routes.analytics),
  _NavTab('Profile', Icons.person_rounded, Routes.profile),
];

/// Floating bottom nav used by every shell screen. Active tab is the one
/// whose route matches the current location; tapping any tab calls
/// `context.go(route)`.
class BottomNav extends StatelessWidget {
  const BottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final String location =
        GoRouterState.of(context).matchedLocation;

    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xD91C1C28)
              : theme.colorScheme.surface,
          border: Border.all(color: theme.dividerColor),
          borderRadius: BorderRadius.circular(22),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
              blurRadius: isDark ? 24 : 16,
              offset: Offset(0, isDark ? -8 : 4),
            ),
          ],
        ),
        child: Row(
          children: <Widget>[
            for (final _NavTab tab in _tabs)
              Expanded(
                child: _Tab(
                  tab: tab,
                  active: location == tab.route,
                  onTap: () {
                    if (location != tab.route) {
                      HapticFeedback.selectionClick();
                      context.go(tab.route);
                    }
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({required this.tab, required this.active, required this.onTap});

  final _NavTab tab;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color accent = theme.colorScheme.primary;
    final Color inactive =
        theme.colorScheme.onSurface.withValues(alpha: 0.45);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          height: 44,
          padding: EdgeInsets.symmetric(horizontal: active ? 14 : 0),
          decoration: BoxDecoration(
            color: active
                ? accent.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(tab.icon, color: active ? accent : inactive, size: 22),
              if (active) ...<Widget>[
                const SizedBox(width: 6),
                Text(
                  tab.label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: accent,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
