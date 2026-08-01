import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';
import 'level_selection_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<SettingsProvider>().isDarkMode;
    final textColor = isDark ? AppTheme.textLight : AppTheme.textDark;
    final bgColor = isDark ? AppTheme.bgDark : AppTheme.bgLight;
    final cardColor = isDark ? const Color(0xFF1E2235) : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'GridSnap',
                style: GoogleFonts.poppins(
                  fontSize: 48,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '3D Arrow Puzzle',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: textColor.withValues(alpha: 0.7),
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 60),
              _buildMenuButton(context, 'PLAY', Icons.play_arrow_rounded, AppTheme.clayBlockLight, cardColor, textColor, () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const LevelSelectionScreen()));
              }),
              const SizedBox(height: 20),
              _buildMenuButton(context, 'SETTINGS', Icons.settings_rounded, Colors.grey, cardColor, textColor, () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, String title, IconData icon, Color iconColor, Color cardColor, Color textColor, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: 200,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 5))
          ]
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor),
            const SizedBox(width: 10),
            Text(
              title,
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
            ),
          ],
        ),
      ),
    );
  }
}
