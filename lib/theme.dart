import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness b) {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF6E6E6E),
      brightness: b,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      textTheme: _textTheme(b),
      cardTheme: const CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(24)),
        ),
      ),
    );
  }

  static TextTheme _textTheme(Brightness b) {
    final base = b == Brightness.dark ? Typography.whiteMountainView : Typography.blackMountainView;
    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(fontWeight: FontWeight.w300),
      headlineLarge: base.headlineLarge?.copyWith(fontWeight: FontWeight.w400),
      titleLarge: base.titleLarge?.copyWith(fontWeight: FontWeight.w600),
      labelLarge: base.labelLarge?.copyWith(letterSpacing: 0.3),
    );
  }
}
