import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand colors
  static const Color primaryLight = Color(0xFF4F46E5); // Indigo 600
  static const Color secondaryLight = Color(0xFF0EA5E9); // Sky 500
  static const Color accentLight = Color(0xFF10B981); // Emerald 500
  static const Color backgroundLight = Color(0xFFF8FAFC); // Slate 50
  static const Color surfaceLight = Colors.white;
  static const Color textPrimaryLight = Color(0xFF0F172A); // Slate 900
  static const Color textSecondaryLight = Color(0xFF475569); // Slate 600
  static const Color borderLight = Color(0xFFE2E8F0); // Slate 200

  static const Color primaryDark = Color(0xFF818CF8); // Indigo 400
  static const Color secondaryDark = Color(0xFF38BDF8); // Sky 400
  static const Color accentDark = Color(0xFF34D399); // Emerald 400
  static const Color backgroundDark = Color(0xFF090D16); // Deep Dark Slate/Navy
  static const Color surfaceDark = Color(0xFF151C2C); // Dark Card/Surface
  static const Color textPrimaryDark = Color(0xFFF1F5F9); // Slate 100
  static const Color textSecondaryDark = Color(0xFF94A3B8); // Slate 400
  static const Color borderDark = Color(0xFF222F43); // Refined dark border

  static ThemeData get lightTheme {
    final base = ThemeData.light(useMaterial3: true);
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryLight,
        brightness: Brightness.light,
        primary: primaryLight,
        secondary: secondaryLight,
        tertiary: accentLight,
        background: backgroundLight,
        surface: surfaceLight,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        outline: borderLight,
      ),
      scaffoldBackgroundColor: backgroundLight,
      textTheme: GoogleFonts.plusJakartaSansTextTheme(base.textTheme).copyWith(
        titleLarge: GoogleFonts.plusJakartaSans(
          color: textPrimaryLight,
          fontWeight: FontWeight.bold,
        ),
        titleMedium: GoogleFonts.plusJakartaSans(
          color: textPrimaryLight,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: GoogleFonts.plusJakartaSans(
          color: textPrimaryLight,
        ),
        bodyMedium: GoogleFonts.plusJakartaSans(
          color: textSecondaryLight,
        ),
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: textPrimaryLight,
        titleTextStyle: TextStyle(
          color: textPrimaryLight,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        iconTheme: IconThemeData(color: primaryLight),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: surfaceLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: borderLight, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: primaryLight,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderLight, width: 1.2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderLight, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryLight, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: const TextStyle(color: textSecondaryLight, fontWeight: FontWeight.w500),
        hintStyle: const TextStyle(color: textSecondaryLight),
        prefixIconColor: textSecondaryLight,
        suffixIconColor: textSecondaryLight,
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        backgroundColor: Colors.white,
        indicatorColor: primaryLight.withOpacity(0.08),
        iconTheme: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const IconThemeData(color: primaryLight, size: 24);
          }
          return const IconThemeData(color: textSecondaryLight, size: 24);
        }),
        labelTextStyle: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const TextStyle(
              color: primaryLight,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            );
          }
          return const TextStyle(
            color: textSecondaryLight,
            fontWeight: FontWeight.w500,
            fontSize: 12,
          );
        }),
      ),
      dividerColor: borderLight,
    );
  }

  static ThemeData get darkTheme {
    final base = ThemeData.dark(useMaterial3: true);
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryDark,
        brightness: Brightness.dark,
        primary: primaryDark,
        secondary: secondaryDark,
        tertiary: accentDark,
        background: backgroundDark,
        surface: surfaceDark,
        onPrimary: backgroundDark,
        onSecondary: backgroundDark,
        outline: borderDark,
      ),
      scaffoldBackgroundColor: backgroundDark,
      textTheme: GoogleFonts.plusJakartaSansTextTheme(base.textTheme).copyWith(
        titleLarge: GoogleFonts.plusJakartaSans(
          color: textPrimaryDark,
          fontWeight: FontWeight.bold,
        ),
        titleMedium: GoogleFonts.plusJakartaSans(
          color: textPrimaryDark,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: GoogleFonts.plusJakartaSans(
          color: textPrimaryDark,
        ),
        bodyMedium: GoogleFonts.plusJakartaSans(
          color: textSecondaryDark,
        ),
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: textPrimaryDark,
        titleTextStyle: TextStyle(
          color: textPrimaryDark,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        iconTheme: IconThemeData(color: primaryDark),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: borderDark, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: primaryDark,
          foregroundColor: backgroundDark,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderDark, width: 1.2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderDark, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryDark, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: const TextStyle(color: textSecondaryDark, fontWeight: FontWeight.w500),
        hintStyle: const TextStyle(color: textSecondaryDark),
        prefixIconColor: textSecondaryDark,
        suffixIconColor: textSecondaryDark,
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        backgroundColor: surfaceDark,
        indicatorColor: primaryDark.withOpacity(0.12),
        iconTheme: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const IconThemeData(color: primaryDark, size: 24);
          }
          return const IconThemeData(color: textSecondaryDark, size: 24);
        }),
        labelTextStyle: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const TextStyle(
              color: primaryDark,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            );
          }
          return const TextStyle(
            color: textSecondaryDark,
            fontWeight: FontWeight.w500,
            fontSize: 12,
          );
        }),
      ),
      dividerColor: borderDark,
    );
  }
}
