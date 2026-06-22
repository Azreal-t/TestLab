import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.deepPurple,
        brightness: Brightness.dark,
        surface: const Color(0xFF12121A),
        onSurface: const Color(0xFFE2E2E9),
        primary: Colors.deepPurpleAccent,
        secondary: Colors.tealAccent,
      ),
      scaffoldBackgroundColor: const Color(0xFF0F0F15),
      cardTheme: const CardThemeData(
        color: Color(0xFF1A1A24),
        elevation: 2,
        margin: EdgeInsets.zero,
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: Colors.deepPurpleAccent,
        unselectedLabelColor: Colors.grey,
        indicatorColor: Colors.deepPurpleAccent,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.grey.withValues(alpha: 0.2),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF161622),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.deepPurpleAccent, width: 2),
        ),
      ),
    );
  }
}
