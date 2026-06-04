import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Primary Colors
  static const Color primaryBlue = Color(0xFF3B82F6); // accent
  static const Color secondaryBlue = Color(0xFF8B5CF6); // secondary (purple)
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);
  
  // Background & Surface
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color backgroundDark = Color(0xFF020617); // darker
  static const Color cardDark = Color(0xFF0F172A); // dark

  // Text Colors
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF64748B);
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: primaryBlue,
        secondary: secondaryBlue,
        surface: cardLight,
        background: backgroundLight,
        error: danger,
      ),
      scaffoldBackgroundColor: backgroundLight,
      cardColor: cardLight,
      textTheme: GoogleFonts.plusJakartaSansTextTheme(ThemeData.light().textTheme).copyWith(
        displayLarge: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: textPrimaryLight),
        displayMedium: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: textPrimaryLight),
        displaySmall: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: textPrimaryLight),
        headlineLarge: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: textPrimaryLight),
        headlineMedium: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: textPrimaryLight),
        headlineSmall: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: textPrimaryLight),
        titleLarge: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, color: textPrimaryLight),
        titleMedium: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, color: textPrimaryLight),
        titleSmall: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, color: textPrimaryLight),
        bodyLarge: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w400, color: textPrimaryLight),
        bodyMedium: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w400, color: textPrimaryLight),
        bodySmall: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w400, color: textSecondaryLight),
        labelLarge: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, color: textPrimaryLight),
      ),
      cardTheme: CardThemeData(
        color: cardLight,
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryBlue, width: 2),
        ),
        hintStyle: GoogleFonts.plusJakartaSans(color: textSecondaryLight),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: primaryBlue,
        secondary: secondaryBlue,
        surface: cardDark,
        background: backgroundDark,
        error: danger,
      ),
      scaffoldBackgroundColor: backgroundDark,
      cardColor: cardDark,
      textTheme: GoogleFonts.plusJakartaSansTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: textPrimaryDark),
        displayMedium: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: textPrimaryDark),
        displaySmall: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: textPrimaryDark),
        headlineLarge: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: textPrimaryDark),
        headlineMedium: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: textPrimaryDark),
        headlineSmall: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: textPrimaryDark),
        titleLarge: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, color: textPrimaryDark),
        titleMedium: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, color: textPrimaryDark),
        titleSmall: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, color: textPrimaryDark),
        bodyLarge: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w400, color: textPrimaryDark),
        bodyMedium: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w400, color: textPrimaryDark),
        bodySmall: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w400, color: textSecondaryDark),
        labelLarge: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, color: textPrimaryDark),
      ),
      cardTheme: CardThemeData(
        color: cardDark,
        elevation: 8,
        shadowColor: Colors.black.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardDark,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade800),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryBlue, width: 2),
        ),
        hintStyle: GoogleFonts.plusJakartaSans(color: textSecondaryDark),
      ),
    );
  }
}
