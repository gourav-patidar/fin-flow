import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/constants/radii.dart';
import '../../core/constants/spacing.dart';
import '../../core/theme/app_colors.dart';

/// A theme-aware card surface used throughout FinFlow.
///
/// In **dark** mode it renders as glassmorphism — a translucent fill with a
/// `BackdropFilter` blur and a soft purple-tinted gradient.
///
/// In **light** mode the blur is dropped (looks muddy on white) and the card
/// keeps a crisp shadow instead.
///
/// Use [variant] = [GlassCardVariant.gradient] for the soft accent-tinted
/// surface (e.g. form card on Sign In). Use [GlassCardVariant.flat] for a
/// plain card surface (e.g. list containers, settings groups).
class GlassCard extends StatelessWidget {
  const GlassCard({
    required this.child,
    this.padding = const EdgeInsets.all(Spacing.s20),
    this.variant = GlassCardVariant.flat,
    this.borderRadius,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final GlassCardVariant variant;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final BorderRadius radius =
        borderRadius ?? BorderRadius.circular(Radii.card);

    final Decoration decoration = _decoration(isDark);

    final Widget content = Container(
      decoration: decoration,
      padding: padding,
      child: child,
    );

    if (isDark) {
      return ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: content,
        ),
      );
    }
    return content;
  }

  Decoration _decoration(bool isDark) {
    final BorderRadius radius =
        borderRadius ?? BorderRadius.circular(Radii.card);
    if (isDark) {
      final List<Color> gradient = variant == GlassCardVariant.gradient
          ? <Color>[
              const Color(0x2E7B6EF6), // rgba(123,110,246,0.18)
              const Color(0x0A7B6EF6), // rgba(123,110,246,0.04)
            ]
          : <Color>[
              AppColorsDark.card.withValues(alpha: 0.55),
              AppColorsDark.card.withValues(alpha: 0.45),
            ];
      return BoxDecoration(
        borderRadius: radius,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
        border: Border.all(color: AppColorsDark.border, width: 1),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x66000000), // 0 8px 32px rgba(0,0,0,0.4)
            blurRadius: 32,
            offset: Offset(0, 8),
          ),
        ],
      );
    }

    final List<Color> gradient = variant == GlassCardVariant.gradient
        ? const <Color>[
            Color(0x1A6358E8), // rgba(99,88,232,0.10)
            Color(0x056358E8), // rgba(99,88,232,0.02)
          ]
        : <Color>[AppColorsLight.card, AppColorsLight.card];

    return BoxDecoration(
      borderRadius: radius,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: gradient,
      ),
      border: Border.all(color: AppColorsLight.border, width: 1),
      boxShadow: const <BoxShadow>[
        BoxShadow(
          color: Color(0x0F0A0A0F), // 0 4px 20px rgba(10,10,15,0.06)
          blurRadius: 20,
          offset: Offset(0, 4),
        ),
        BoxShadow(
          color: Color(0x0A0A0A0F), // 0 1px 2px rgba(10,10,15,0.04)
          blurRadius: 2,
          offset: Offset(0, 1),
        ),
      ],
    );
  }
}

enum GlassCardVariant { flat, gradient }
