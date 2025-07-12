import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors - Šahovska tema
  static const Color primary = Color(0xFF2C3E50); // Tamno plava
  static const Color primaryLight = Color(0xFF34495E);
  static const Color primaryDark = Color(0xFF1A252F);

  // Secondary Colors
  static const Color secondary = Color(0xFFE67E22); // Narandžasta
  static const Color secondaryLight = Color(0xFFF39C12);
  static const Color secondaryDark = Color(0xFFD35400);

  // Accent Colors
  static const Color accent = Color(0xFF3498DB); // Svetlo plava
  static const Color accentLight = Color(0xFF5DADE2);
  static const Color accentDark = Color(0xFF2980B9);

  // Background Colors
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F5F5);

  // Text Colors
  static const Color textPrimary = Color(0xFF2C3E50);
  static const Color textSecondary = Color(0xFF7F8C8D);
  static const Color textHint = Color(0xFFBDC3C7);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnSecondary = Color(0xFFFFFFFF);

  // Status Colors
  static const Color success = Color(0xFF27AE60);
  static const Color warning = Color(0xFFF39C12);
  static const Color error = Color(0xFFE74C3C);
  static const Color info = Color(0xFF3498DB);

  // Notification Type Colors
  static const Color generalNotification = Color(0xFF3498DB); // Plava
  static const Color tournamentNotification = Color(0xFFE67E22); // Narandžasta
  static const Color campNotification = Color(0xFF27AE60); // Zelena
  static const Color trainingNotification = Color(0xFF9B59B6); // Ljubičasta

  // Card Colors
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color cardShadow = Color(0x1A000000);
  static const Color cardBorder = Color(0xFFE1E8ED);

  // Button Colors
  static const Color buttonPrimary = primary;
  static const Color buttonSecondary = secondary;
  static const Color buttonDisabled = Color(0xFFBDC3C7);
  static const Color buttonText = Color(0xFFFFFFFF);

  // Input Field Colors
  static const Color inputBackground = Color(0xFFF8F9FA);
  static const Color inputBorder = Color(0xFFE1E8ED);
  static const Color inputBorderFocused = primary;
  static const Color inputText = textPrimary;
  static const Color inputHint = textHint;

  // Navigation Colors
  static const Color navigationBackground = Color(0xFFFFFFFF);
  static const Color navigationSelected = primary;
  static const Color navigationUnselected = textSecondary;

  // Divider and Border Colors
  static const Color divider = Color(0xFFE1E8ED);
  static const Color border = Color(0xFFBDC3C7);
  static const Color borderLight = Color(0xFFE1E8ED);

  // Shimmer Colors
  static const Color shimmerBase = Color(0xFFE0E0E0);
  static const Color shimmerHighlight = Color(0xFFF5F5F5);

  // Overlay Colors
  static const Color overlay = Color(0x80000000);
  static const Color modalBarrier = Color(0x80000000);

  // Chess-specific Colors
  static const Color chessWhite = Color(0xFFF0D9B5);
  static const Color chessBlack = Color(0xFFB58863);
  static const Color chessHighlight = Color(0xFFFFFF00);

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark],
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondary, secondaryDark],
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [background, surfaceVariant],
  );

  // Helper methods
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }

  static Color darken(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }

  static Color lighten(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
    return hslLight.toColor();
  }
}