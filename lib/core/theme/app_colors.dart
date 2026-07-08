import 'package:flutter/material.dart';

class AppColors {
  // PRIMARY - White (was purple 0xFF6C63FF)
  static const Color primary = Colors.white;
  static const Color primaryLight = Colors.white70;
  static const Color primaryDark = Colors.white;

  // SECONDARY - Gray (was teal 0xFF00BFA6)
  static const Color secondary = Colors.white;
  static const Color secondaryLight = Colors.white70;
  static const Color secondaryDark = Colors.white;

  // ACCENT - White (was pink 0xFFFF6584)
  static const Color accent = Colors.white;
  static const Color accentLight = Colors.white70;

  // STATUS - White/Gray only
  static const Color success = Colors.white;
  static const Color warning = Colors.white70;
  static const Color error = Colors.white;
  static const Color info = Colors.white70;

  static const Color infoColor = info;
  static const Color successColor = success;
  static const Color warningColor = warning;
  static const Color errorColor = error;

  // DARK THEME - Pure Black/Gray (was blue-purple)
  static const Color darkBackground = Colors.black;
  static const Color darkSurface = Color(0xFF111111);
  static const Color darkCard = Color(0xFF1A1A1A);
  static const Color darkText = Colors.white;
  static const Color darkTextMuted = Colors.white70;

  // LIGHT THEME - White/Gray (for completeness)
  static const Color lightBackground = Colors.white;
  static const Color lightSurface = Color(0xFFF5F5F5);
  static const Color lightCard = Colors.white;
  static const Color lightText = Colors.black;
  static const Color lightTextMuted = Colors.black54;

  // Current theme colors
  static const Color background = darkBackground;
  static const Color surface = darkSurface;
  static const Color card = darkCard;
  static const Color text = darkText;
  static const Color textMuted = darkTextMuted;

  // GRADIENTS - Black to Gray only (was purple gradients)
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Colors.black, Color(0xFF111111)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [Colors.black, Color(0xFF111111)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF1A1A1A), Color(0xFF222222)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
