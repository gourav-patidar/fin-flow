import 'package:flutter/material.dart';

import '../../core/constants/radii.dart';
import '../../core/constants/spacing.dart';
import '../../core/theme/app_colors.dart';

/// The primary CTA button. Renders the accent gradient with a soft glow
/// shadow so it reads as the most important action on a screen.
///
/// While [isLoading] is true the label is replaced with a spinner and taps
/// are blocked. `onPressed` may be null to render a disabled state.
class GradientButton extends StatelessWidget {
  const GradientButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.fullWidth = true,
    this.borderRadius,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool fullWidth;

  /// Override the default [Radii.button] (14). Onboarding uses 18 per design.
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final List<Color> gradient = isDark
        ? AppColorsDark.gradientHero
        : AppColorsLight.gradientHero;
    final bool disabled = onPressed == null || isLoading;
    final double radius = borderRadius ?? Radii.button;

    final Widget content = isLoading
        ? const SizedBox(
            height: 22,
            width: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                ),
              ),
              if (icon != null) ...<Widget>[
                const SizedBox(width: Spacing.s8),
                Icon(icon, color: Colors.white, size: 18),
              ],
            ],
          );

    return Opacity(
      opacity: disabled && !isLoading ? 0.5 : 1.0,
      child: SizedBox(
        width: fullWidth ? double.infinity : null,
        height: 56,
        child: Material(
          color: Colors.transparent,
          child: Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradient,
              ),
              borderRadius: BorderRadius.circular(radius),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: (isDark
                          ? AppColorsDark.accent
                          : AppColorsLight.accent)
                      .withValues(alpha: isDark ? 0.55 : 0.4),
                  blurRadius: isDark ? 32 : 28,
                  offset: const Offset(0, 16),
                  spreadRadius: -8,
                ),
              ],
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(radius),
              onTap: disabled ? null : onPressed,
              child: Center(child: content),
            ),
          ),
        ),
      ),
    );
  }
}
