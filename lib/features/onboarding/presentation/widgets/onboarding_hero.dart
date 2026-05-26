import 'package:flutter/material.dart';

/// Placeholder visual for an onboarding slide — a soft gradient blob with a
/// centered icon, sized at ~440px tall to match the design's hero region.
///
/// TODO(asset): replace each instance with a Lottie animation in
/// `assets/lottie/onboarding_{1,2,3}.json`:
///   * Slide 1 → "wallet/cards floating + cash counter"
///   * Slide 2 → "donut chart drawing in + insight card"
///   * Slide 3 → "progress rings filling + trophy reveal"
class OnboardingHero extends StatelessWidget {
  const OnboardingHero({
    required this.icon,
    required this.primaryGlow,
    this.secondaryGlow,
    super.key,
  });

  final IconData icon;
  final Color primaryGlow;
  final Color? secondaryGlow;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final double glowOpacity = isDark ? 1.0 : 0.7;

    return SizedBox(
      height: 360,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          // Primary radial glow
          IgnorePointer(
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: <Color>[
                    primaryGlow.withValues(alpha: 0.35 * glowOpacity),
                    primaryGlow.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),

          // Secondary glow (offset)
          if (secondaryGlow != null)
            Positioned(
              bottom: 20,
              right: 0,
              child: IgnorePointer(
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: <Color>[
                        secondaryGlow!.withValues(alpha: 0.18 * glowOpacity),
                        secondaryGlow!.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // Centered icon disc
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(36),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[primaryGlow, primaryGlow.withValues(alpha: 0.7)],
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: primaryGlow.withValues(alpha: isDark ? 0.55 : 0.35),
                  blurRadius: 40,
                  offset: const Offset(0, 20),
                  spreadRadius: -10,
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 64),
          ),
        ],
      ),
    );
  }
}
