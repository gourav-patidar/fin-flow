import 'package:flutter/material.dart';

/// Dark-mode design tokens. Mirror of `CLAUDE.md` section 4 — keep in sync.
class AppColorsDark {
  const AppColorsDark._();

  static const Color bg = Color(0xFF0A0A0F);
  static const Color surface = Color(0xFF13131A);
  static const Color card = Color(0xFF1C1C28);
  static const Color cardElevated = Color(0xFF232334);

  static const Color border = Color(0x14FFFFFF); // rgba(255,255,255,0.08)
  static const Color borderStrong = Color(0x24FFFFFF); // rgba(255,255,255,0.14)

  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8A8A9A);
  static const Color textTertiary = Color(0xFF5A5A6A);

  static const Color accent = Color(0xFF7B6EF6);
  static const Color accentSoft = Color(0x267B6EF6); // rgba(123,110,246,0.15)

  static const Color income = Color(0xFF00D4AA);
  static const Color expense = Color(0xFFFF5C5C);
  static const Color warning = Color(0xFFFFB547);

  static const List<Color> gradientHero = <Color>[
    Color(0xFF7B6EF6),
    Color(0xFF5B4FE0),
  ];
}

/// Light-mode design tokens. Mirror of `CLAUDE.md` section 4 — keep in sync.
class AppColorsLight {
  const AppColorsLight._();

  static const Color bg = Color(0xFFF5F5F8);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color card = Color(0xFFFFFFFF);
  static const Color cardElevated = Color(0xFFFAFAFC);

  static const Color border = Color(0x0F0A0A0F); // rgba(10,10,15,0.06)
  static const Color borderStrong = Color(0x1F0A0A0F); // rgba(10,10,15,0.12)

  static const Color textPrimary = Color(0xFF0A0A0F);
  static const Color textSecondary = Color(0xFF6B6B7B);
  static const Color textTertiary = Color(0xFFA0A0B0);

  // Intentionally darker than the dark-mode accent for AA contrast on white.
  static const Color accent = Color(0xFF6358E8);
  static const Color accentSoft = Color(0x1A6358E8); // rgba(99,88,232,0.10)

  static const Color income = Color(0xFF00B894);
  static const Color expense = Color(0xFFE53E3E);
  static const Color warning = Color(0xFFE89B2A);

  static const List<Color> gradientHero = <Color>[
    Color(0xFF6358E8),
    Color(0xFF4A3FC9),
  ];
}
