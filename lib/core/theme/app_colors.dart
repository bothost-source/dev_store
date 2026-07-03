import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryLight = Color(0xFF8B85FF);
  static const Color primaryDark = Color(0xFF5046E5);

  static const Color secondary = Color(0xFF00BFA6);
  static const Color secondaryLight = Color(0xFF33CBB5);
  static const Color secondaryDark = Color(0xFF00A38D);

  static const Color accent = Color(0xFFFF6584);
  static const Color accentLight = Color(0xFFFF8BA0);

  static const Color success = Color(0xFF00B894);
  static const Color warning = Color(0xFFF39C12);
  static const Color error = Color(0xFFE74C3C);
  static const Color info = Color(0xFF3498DB);

  static const Color infoColor = info;
  static const Color successColor = success;
  static const Color warningColor = warning;
  static const Color errorColor = error;

  static const Color darkBackground = Color(0xFF1A1A2E);
  static const Color darkSurface = Color(0xFF16213E);
  static const Color darkCard = Color(0xFF0F3460);
  static const Color darkText = Color(0xFFF8F9FA);
  static const Color darkTextMuted = Color(0xFF95A5A6);

  static const Color lightBackground = Color(0xFFF8F9FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightText = Color(0xFF2D3436);
  static const Color lightTextMuted = Color(0xFF636E72);

  // CHANGED: static const instead of getters for const compatibility
  static const Color background = lightBackground;
  static const Color surface = lightSurface;
  static const Color card = lightCard;
  static const Color text = lightText;
  static const Color textMuted = lightTextMuted;

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [darkBackground, darkSurface],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accent, accentLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
