import 'package:flutter/material.dart';

import '../../core/constants/radii.dart';
import '../../core/constants/spacing.dart';

/// An outlined / soft-tinted alternative to [GradientButton]. Use it for
/// secondary actions like "Google sign-in", "Cancel", or social/biometric
/// chips that sit alongside the primary CTA.
///
/// [variant] controls whether the button looks like a neutral card-style
/// chip ([SecondaryButtonVariant.outlined]) or an accent-tinted pill
/// ([SecondaryButtonVariant.accent]).
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.variant = SecondaryButtonVariant.outlined,
    this.fullWidth = true,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;
  final SecondaryButtonVariant variant;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final Color accent = theme.colorScheme.primary;
    final bool isAccent = variant == SecondaryButtonVariant.accent;

    final Color bg = isAccent
        ? accent.withValues(alpha: isDark ? 0.15 : 0.10)
        : theme.cardTheme.color ?? theme.colorScheme.surface;
    final Color borderColor = isAccent
        ? accent.withValues(alpha: isDark ? 0.25 : 0.18)
        : theme.dividerColor;
    final Color textColor = isAccent ? accent : theme.colorScheme.onSurface;

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: 52,
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(Radii.button),
        child: InkWell(
          borderRadius: BorderRadius.circular(Radii.button),
          onTap: onPressed,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Radii.button),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                if (icon != null) ...<Widget>[
                  IconTheme(
                    data: IconThemeData(color: textColor, size: 18),
                    child: icon!,
                  ),
                  const SizedBox(width: Spacing.s8),
                ],
                Text(
                  label,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum SecondaryButtonVariant { outlined, accent }
