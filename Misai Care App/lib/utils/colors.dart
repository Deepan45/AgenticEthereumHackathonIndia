import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primaryBlue = Color(0xFF1A4D9E);
  static const Color lightBlue = Color(0xFF2D5FBF);
  static const Color darkBlue = Color(0xFF0F2F5F);
  static const Color primaryGreen = Color(0xFF5BCC6A);
  static const Color lightGreen = Color(0xFF7DD87F);

  // Background Colors
  static const Color scaffoldBackground = Color(0xFFF8FAFC);
  static const Color cardBackground = Color(0xFFFFFFFF);

  // Text Colors
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textDisabled = Color(0xFF94A3B8);

  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Additional Colors
  static const Color divider = Color(0xFFE2E8F0);
  static const Color border = Color(0xFFCBD5E1);
  static const Color highlight = Color(0xFFF1F5F9);

  // Gradients
  static LinearGradient blueGradient = LinearGradient(
    colors: [primaryBlue, lightBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient greenGradient = LinearGradient(
    colors: [primaryGreen, lightGreen],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Helper Methods
  static Color getScoreColor(int score) {
    return score > 80
        ? success
        : score > 60
            ? warning
            : error;
  }
}