import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors
  static const background = Color(0xFF0A0A0A);
  static const card = Color(0xFF1C1C1E);
  static const accent = Color(0xFF3B82F6);
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFF8E8E93);
  static const blue = Color(0xFF3B82F6);
  static const green = Color(0xFF10B981);
  static const orange = Color(0xFFF59E0B);
  static const red = Color(0xFFEF4444);
  static const purple = Color(0xFF8B5CF6);

  static ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: background,
    colorScheme: const ColorScheme.dark(
      primary: accent,
      background: background,
      surface: card,
    ),
    textTheme: GoogleFonts.dmSansTextTheme(
      ThemeData.dark().textTheme,
    ).apply(
      bodyColor: textPrimary,
      displayColor: textPrimary,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: background,
      elevation: 0,
      iconTheme: IconThemeData(color: textPrimary),
      titleTextStyle: TextStyle(
        color: textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accent,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    ),
    sliderTheme: const SliderThemeData(
      activeTrackColor: accent,
      thumbColor: accent,
      inactiveTrackColor: card,
    ),
    tabBarTheme: const TabBarTheme(
      labelColor: textPrimary,
      unselectedLabelColor: textSecondary,
      indicatorColor: accent,
    ),
  );
}
