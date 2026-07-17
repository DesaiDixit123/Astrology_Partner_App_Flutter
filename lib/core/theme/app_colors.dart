import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors - Blue Theme for Partner App
  static const Color primary = Color(0xFF1E88E5);
  static const Color primaryDark = Color(0xFF1565C0);
  static const Color primaryLight = Color(0xFF42A5F5);

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1E88E5), Color(0xFF1565C0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Secondary Colors
  static const Color secondary = Color(0xFF26C6DA);
  static const Color secondaryDark = Color(0xFF00ACC1);

  // Accent Colors
  static const Color accent = Color(0xFFFF9800); // For earnings/money
  static const Color accentLight = Color(0xFFFFB74D);

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // Background Colors
  static const Color background = Color(0xFFF5F7FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF0F4F8);

  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);
  static const Color textWhite = Color(0xFFFFFFFF);

  // Border & Divider
  static const Color border = Color(0xFFE0E0E0);
  static const Color divider = Color(0xFFEEEEEE);

  // Shadow
  static const Color shadow = Color(0x1A000000);

  // Online/Offline Status
  static const Color online = Color(0xFF4CAF50);
  static const Color offline = Color(0xFF9E9E9E);

  // Missing members restored for compatibility
  static const Color gold = Color(0xFFFFD700);
  static const Color deepCosmic = Color(0xFF0D1B2A);
  static const List<BoxShadow> softShadow = [
    BoxShadow(
      color: shadow,
      blurRadius: 10,
      offset: Offset(0, 4),
    ),
  ];
  static const LinearGradient cosmicGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
