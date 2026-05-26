import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// The FinFlow brand mark — gradient square with a stylised "F" glyph.
/// Scales with [size]; default 48 matches the Sign In hero.
///
/// TODO(asset): swap the placeholder Icon for the final F-mark SVG.
class BrandMark extends StatelessWidget {
  const BrandMark({this.size = 48, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final List<Color> gradient =
        isDark ? AppColorsDark.gradientHero : AppColorsLight.gradientHero;
    final double radius = size * 0.29; // 14 at size 48
    final double glow = size * 0.83; // 40 at size 48

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: gradient.first.withValues(alpha: isDark ? 0.55 : 0.4),
            blurRadius: glow,
            offset: Offset(0, size * 0.33),
            spreadRadius: -size * 0.21,
          ),
        ],
      ),
      child: Center(
        child: Text(
          'F',
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.55,
            fontWeight: FontWeight.w700,
            letterSpacing: -1.5,
            height: 1,
          ),
        ),
      ),
    );
  }
}
