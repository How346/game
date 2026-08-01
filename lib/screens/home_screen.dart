import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/game_theme.dart';
import 'level_selection_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameTheme.bgPrimary,
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
                  color: GameTheme.textDark,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '3D Arrow Puzzle',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: GameTheme.textLight,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 60),
              _buildMenuButton(context, 'PLAY', Icons.play_arrow_rounded, GameTheme.upColor, () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const LevelSelectionScreen()));
              }),
              const SizedBox(height: 20),
              _buildMenuButton(context, 'SETTINGS', Icons.settings_rounded, GameTheme.textLight, () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: 200,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: GameTheme.blockSurface,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))
          ]
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 10),
            Text(
              title,
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: GameTheme.textDark),
            ),
          ],
        ),
      ),
    );
  }
}
