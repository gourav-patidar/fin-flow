import 'package:flutter/material.dart';

import '../../../../core/constants/spacing.dart';
import 'onboarding_hero.dart';

/// Content for a single onboarding slide. Pure layout — no PageView logic;
/// pagination/CTA lives in the parent screen.
class OnboardingSlide extends StatelessWidget {
  const OnboardingSlide({
    required this.eyebrow,
    required this.title,
    required this.titleAccent,
    required this.description,
    required this.icon,
    required this.primaryGlow,
    this.secondaryGlow,
    this.accentColor,
    super.key,
  });

  final String eyebrow;
  final String title;
  final String titleAccent;
  final String description;
  final IconData icon;
  final Color primaryGlow;
  final Color? secondaryGlow;

  /// Color for the second line of the title. Defaults to theme accent.
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color accent = accentColor ?? theme.colorScheme.primary;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox(height: Spacing.s24),
          OnboardingHero(
            icon: icon,
            primaryGlow: primaryGlow,
            secondaryGlow: secondaryGlow,
          ),
          const SizedBox(height: Spacing.s8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  eyebrow,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: Spacing.s12),
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      height: 1.15,
                      letterSpacing: -1,
                      color: theme.colorScheme.onSurface,
                    ),
                    children: <InlineSpan>[
                      TextSpan(text: '$title\n'),
                      TextSpan(
                        text: titleAccent,
                        style: TextStyle(color: accent),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: 320,
                  child: Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      height: 1.55,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
