import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Central `ThemeData` factory for FinFlow. Both themes use DM Sans with
/// tabular figures so currency lines up across rows.
class AppTheme {
  const AppTheme._();

  static ThemeData get light => _build(_LightPalette());
  static ThemeData get dark => _build(_DarkPalette());

  static ThemeData _build(_Palette p) {
    final TextTheme base = GoogleFonts.dmSansTextTheme(
      ThemeData(brightness: p.brightness).textTheme,
    );

    final TextTheme tabular = base.apply(
      bodyColor: p.textPrimary,
      displayColor: p.textPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: p.brightness,
      scaffoldBackgroundColor: p.bg,
      canvasColor: p.bg,
      colorScheme: ColorScheme(
        brightness: p.brightness,
        primary: p.accent,
        onPrimary: Colors.white,
        secondary: p.accent,
        onSecondary: Colors.white,
        error: p.expense,
        onError: Colors.white,
        surface: p.surface,
        onSurface: p.textPrimary,
      ),
      textTheme: tabular.copyWith(
        bodyLarge: tabular.bodyLarge?.copyWith(
          fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
        ),
        bodyMedium: tabular.bodyMedium?.copyWith(
          fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
        ),
        titleLarge: tabular.titleLarge?.copyWith(
          fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: p.card,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: p.accent,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.cardElevated,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        hintStyle: TextStyle(color: p.textTertiary),
        labelStyle: TextStyle(color: p.textSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: p.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: p.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: p.accent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: p.expense),
        ),
      ),
      dividerColor: p.border,
      iconTheme: IconThemeData(color: p.textSecondary),
      appBarTheme: AppBarTheme(
        backgroundColor: p.bg,
        foregroundColor: p.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
    );
  }
}

abstract class _Palette {
  Brightness get brightness;
  Color get bg;
  Color get surface;
  Color get card;
  Color get cardElevated;
  Color get border;
  Color get accent;
  Color get textPrimary;
  Color get textSecondary;
  Color get textTertiary;
  Color get expense;
}

class _DarkPalette implements _Palette {
  @override
  Brightness get brightness => Brightness.dark;
  @override
  Color get bg => AppColorsDark.bg;
  @override
  Color get surface => AppColorsDark.surface;
  @override
  Color get card => AppColorsDark.card;
  @override
  Color get cardElevated => AppColorsDark.cardElevated;
  @override
  Color get border => AppColorsDark.border;
  @override
  Color get accent => AppColorsDark.accent;
  @override
  Color get textPrimary => AppColorsDark.textPrimary;
  @override
  Color get textSecondary => AppColorsDark.textSecondary;
  @override
  Color get textTertiary => AppColorsDark.textTertiary;
  @override
  Color get expense => AppColorsDark.expense;
}

class _LightPalette implements _Palette {
  @override
  Brightness get brightness => Brightness.light;
  @override
  Color get bg => AppColorsLight.bg;
  @override
  Color get surface => AppColorsLight.surface;
  @override
  Color get card => AppColorsLight.card;
  @override
  Color get cardElevated => AppColorsLight.cardElevated;
  @override
  Color get border => AppColorsLight.border;
  @override
  Color get accent => AppColorsLight.accent;
  @override
  Color get textPrimary => AppColorsLight.textPrimary;
  @override
  Color get textSecondary => AppColorsLight.textSecondary;
  @override
  Color get textTertiary => AppColorsLight.textTertiary;
  @override
  Color get expense => AppColorsLight.expense;
}
