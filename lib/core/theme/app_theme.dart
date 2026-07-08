import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // BLACK & WHITE ONLY
  static const Color primaryColor = Colors.white;
  static const Color secondaryColor = Colors.white;
  static const Color accentColor = Colors.white;
  static const Color darkBackground = Colors.black;
  static const Color darkSurface = Color(0xFF111111);
  static const Color darkCard = Color(0xFF1A1A1A);
  static const Color lightBackground = Colors.white;
  static const Color lightSurface = Color(0xFFF5F5F5);
  static const Color lightCard = Colors.white;
  static const Color textDark = Colors.black;
  static const Color textLight = Colors.white;
  static const Color textMuted = Colors.white70;
  static const Color errorColor = Colors.white;
  static const Color successColor = Colors.white;
  static const Color warningColor = Colors.white70;
  static const Color infoColor = Colors.white70;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightBackground,
      primaryColor: Colors.black,
      colorScheme: const ColorScheme.light(
        primary: Colors.black,
        secondary: Colors.black,
        surface: lightSurface,
        background: lightBackground,
        error: Colors.black,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.black,
        onBackground: Colors.black,
        onError: Colors.white,
      ),
      textTheme: GoogleFonts.poppinsTextTheme().copyWith(
        displayLarge: GoogleFonts.poppins(
          fontSize: 32, fontWeight: FontWeight.bold, color: textDark,
        ),
        displayMedium: GoogleFonts.poppins(
          fontSize: 24, fontWeight: FontWeight.bold, color: textDark,
        ),
        displaySmall: GoogleFonts.poppins(
          fontSize: 20, fontWeight: FontWeight.w600, color: textDark,
        ),
        headlineMedium: GoogleFonts.poppins(
          fontSize: 18, fontWeight: FontWeight.w600, color: textDark,
        ),
        titleLarge: GoogleFonts.poppins(
          fontSize: 16, fontWeight: FontWeight.w600, color: textDark,
        ),
        bodyLarge: GoogleFonts.poppins(
          fontSize: 16, color: textDark,
        ),
        bodyMedium: GoogleFonts.poppins(
          fontSize: 14, color: textDark,
        ),
        bodySmall: GoogleFonts.poppins(
          fontSize: 12, color: Colors.black54,
        ),
      ),
      cardTheme: CardTheme(
        color: lightCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Colors.black12),
        ),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: lightSurface,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20, fontWeight: FontWeight.w600, color: textDark,
        ),
        iconTheme: const IconThemeData(color: textDark),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: lightSurface,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black54,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.poppins(
            fontSize: 16, fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.black,
          side: const BorderSide(color: Colors.black, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.poppins(
            fontSize: 16, fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: GoogleFonts.poppins(fontSize: 14, color: Colors.black54),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.black.withOpacity(0.05),
        selectedColor: Colors.black,
        labelStyle: GoogleFonts.poppins(fontSize: 12, color: Colors.black),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      dividerTheme: const DividerThemeData(
        color: Colors.black12,
        thickness: 1,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,
      primaryColor: Colors.white,
      colorScheme: const ColorScheme.dark(
        primary: Colors.white,
        secondary: Colors.white,
        surface: darkSurface,
        background: darkBackground,
        error: Colors.white,
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onSurface: Colors.white,
        onBackground: Colors.white,
        onError: Colors.black,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.poppins(
          fontSize: 32, fontWeight: FontWeight.bold, color: textLight,
        ),
        displayMedium: GoogleFonts.poppins(
          fontSize: 24, fontWeight: FontWeight.bold, color: textLight,
        ),
        displaySmall: GoogleFonts.poppins(
          fontSize: 20, fontWeight: FontWeight.w600, color: textLight,
        ),
        headlineMedium: GoogleFonts.poppins(
          fontSize: 18, fontWeight: FontWeight.w600, color: textLight,
        ),
        titleLarge: GoogleFonts.poppins(
          fontSize: 16, fontWeight: FontWeight.w600, color: textLight,
        ),
        bodyLarge: GoogleFonts.poppins(
          fontSize: 16, color: textLight,
        ),
        bodyMedium: GoogleFonts.poppins(
          fontSize: 14, color: textLight,
        ),
        bodySmall: GoogleFonts.poppins(
          fontSize: 12, color: textMuted,
        ),
      ),
      cardTheme: CardTheme(
        color: darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Colors.white12),
        ),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: darkSurface,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20, fontWeight: FontWeight.w600, color: textLight,
        ),
        iconTheme: const IconThemeData(color: textLight),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: darkSurface,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white54,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.poppins(
            fontSize: 16, fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: const BorderSide(color: Colors.white, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.poppins(
            fontSize: 16, fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: GoogleFonts.poppins(fontSize: 14, color: textMuted),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.white.withOpacity(0.1),
        selectedColor: Colors.white,
        labelStyle: GoogleFonts.poppins(fontSize: 12, color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      dividerTheme: const DividerThemeData(
        color: Colors.white12,
        thickness: 1,
      ),
    );
  }
}
