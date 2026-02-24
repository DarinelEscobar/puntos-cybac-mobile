import 'package:flutter/material.dart';

class AppTheme {
  // Colors from design
  static const Color primary = Color(0xFF195DE6);
  static const Color backgroundLight = Color(0xFFF6F6F8);
  static const Color backgroundDark = Color(0xFF111621);

  static const Color surfaceLight = Colors.white;
  static const Color surfaceDark = Color(0xFF1A2233);

  static const Color textPrimaryLight = Color(0xFF0E121B);
  static const Color textSecondaryLight = Color(0xFF4E6797);

  static ThemeData light() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        secondary: const Color(0xFF1442A0), // Premium Blue from design
        surface: surfaceLight,
        background: backgroundLight,
        brightness: Brightness.light,
      ),
      useMaterial3: true,
      scaffoldBackgroundColor: backgroundLight,
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundLight,
        foregroundColor: textPrimaryLight,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: textPrimaryLight,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          fontFamily: 'Inter',
        ),
      ),
      fontFamily: 'Inter',
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontFamily: 'Inter', color: textPrimaryLight),
        displayMedium: TextStyle(fontFamily: 'Inter', color: textPrimaryLight),
        displaySmall: TextStyle(fontFamily: 'Inter', color: textPrimaryLight),
        headlineLarge: TextStyle(fontFamily: 'Inter', color: textPrimaryLight),
        headlineMedium: TextStyle(fontFamily: 'Inter', color: textPrimaryLight),
        headlineSmall: TextStyle(fontFamily: 'Inter', color: textPrimaryLight),
        titleLarge: TextStyle(fontFamily: 'Inter', color: textPrimaryLight),
        titleMedium: TextStyle(fontFamily: 'Inter', color: textPrimaryLight),
        titleSmall: TextStyle(fontFamily: 'Inter', color: textPrimaryLight),
        bodyLarge: TextStyle(fontFamily: 'Inter', color: textPrimaryLight),
        bodyMedium: TextStyle(fontFamily: 'Inter', color: textPrimaryLight),
        bodySmall: TextStyle(fontFamily: 'Inter', color: textSecondaryLight),
        labelLarge: TextStyle(fontFamily: 'Inter', color: textPrimaryLight),
      ),
      cardTheme: CardTheme(
        color: surfaceLight,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.05),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          elevation: 4,
          shadowColor: primary.withOpacity(0.3),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: primary),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        contentPadding: const EdgeInsets.all(16),
        hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
      ),
    );
  }
}
