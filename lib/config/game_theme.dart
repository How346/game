import 'package:flutter/material.dart';

class GameTheme {
  static const String appName = 'GridSnap';
  static const int maxHearts = 3;
  static const int totalLevels = 100;

  // Premium Light Theme Colors
  static const Color bgPrimary = Color(0xFFF8F9FA);
  static const Color bgSecondary = Color(0xFFE9ECEF);
  static const Color textDark = Color(0xFF2B2D42);
  static const Color textLight = Color(0xFF8D99AE);
  
  // Arrow Colors (Bright & Colorful)
  static const Color upColor = Color(0xFF4361EE);    // Blue
  static const Color downColor = Color(0xFFF72585);  // Pink/Red
  static const Color leftColor = Color(0xFF4CC9F0);  // Light Blue
  static const Color rightColor = Color(0xFF7209B7); // Purple
  
  static const Color blockSurface = Colors.white;
  static const Color highlightColor = Color(0xFFFFD166); // Yellow hint

  static const Color success = Color(0xFF06D6A0);
  static const Color danger = Color(0xFFEF476F);
}
