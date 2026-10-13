import 'package:flutter/material.dart';

class AppTheme {
  static const blue = Color(0xFF2A70CE);
  static const blueGradient = LinearGradient(
    colors: [Color(0xFF2C73D2), Color(0xFF1E5BB8)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  static const blueButtonGradient = LinearGradient(
    colors: [Color(0xFF2C73D2), Color(0xFF1E5BB8)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
  static const ink = Color(0xFF353535);
  static const muted = Color(0xFF6A7282);
  static const canvas = Color(0xFFF9FAFB);
  static const field = Color(0xFFEBF3FE);

  static final light = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: blue,
      primary: blue,
      surface: Colors.white,
    ),
    scaffoldBackgroundColor: canvas,
    fontFamily: 'Roboto',
    appBarTheme: const AppBarTheme(
      backgroundColor: canvas,
      foregroundColor: ink,
      centerTitle: false,
    ),
    textTheme: const TextTheme(
      headlineMedium: TextStyle(
        color: ink,
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
      titleLarge: TextStyle(
        color: ink,
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
      bodyMedium: TextStyle(color: muted, fontSize: 12),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: field,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0x4D2C73D2)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0x4D2C73D2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: blue, width: 1.5),
      ),
    ),
  );
}
