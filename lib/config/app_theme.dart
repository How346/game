import 'package:flutter/material.dart';

class AppTheme {
  // Light Mode Colors (Reference: 1000651340.jpg & 1000651338.jpg)
  static const Color bgLight = Color(0xFFF4F6F9);
  static const Color textDark = Color(0xFF1A1A24);
  static const Color clayBlockLight = Color(0xFFE93B81); // The pink block
  static const Color clayShadowLight = Color(0xFF1A0000); 

  // Dark Mode Colors (Reference: 1000651336.jpg)
  static const Color bgDark = Color(0xFF111424);
  static const Color textLight = Color(0xFFF4F6F9);
  static const Color clayBlockDark = Color(0xFF4361EE);
  static const Color clayShadowDark = Colors.black;

  static ThemeData get lightTheme => ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: bgLight,
    primaryColor: clayBlockLight,
    textTheme: const TextTheme(bodyLarge: TextStyle(color: textDark)),
  );

  static ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: bgDark,
    primaryColor: clayBlockDark,
    textTheme: const TextTheme(bodyLarge: TextStyle(color: textLight)),
  );
}
