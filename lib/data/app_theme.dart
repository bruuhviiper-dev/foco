import 'package:flutter/material.dart';

/// Tema do app — tons de verde (foco / aprovação).
class AppTheme {
  AppTheme._();

  static const brand = Color(0xFF10B981); // esmeralda
  static const brandDark = Color(0xFF047857);
  static const gold = Color(0xFFA7F3D0);

  /// Gradiente da "frase do dia" e da marca.
  static const hero = [Color(0xFF11998E), Color(0xFF38EF7D)];

  static LinearGradient gradient(List<Color> colors) => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: colors,
      );

  static ThemeData light([Color accent = brand]) {
    return ThemeData(
      useMaterial3: true,
      colorScheme:
          ColorScheme.fromSeed(seedColor: accent, brightness: Brightness.light),
      scaffoldBackgroundColor: const Color(0xFFF4FBF7),
      appBarTheme: const AppBarTheme(centerTitle: false),
    );
  }

  static ThemeData dark([Color accent = brand]) {
    return ThemeData(
      useMaterial3: true,
      colorScheme:
          ColorScheme.fromSeed(seedColor: accent, brightness: Brightness.dark),
      scaffoldBackgroundColor: const Color(0xFF0E1512),
      appBarTheme: const AppBarTheme(centerTitle: false),
    );
  }
}
