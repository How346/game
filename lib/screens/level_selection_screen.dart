import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/game_theme.dart';
import '../services/storage_service.dart';
import 'game_screen.dart';

class LevelSelectionScreen extends StatefulWidget {
  const LevelSelectionScreen({super.key});

  @override
  State<LevelSelectionScreen> createState() => _LevelSelectionScreenState();
}

class _LevelSelectionScreenState extends State<LevelSelectionScreen> {
  int unlockedLevel = 1;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  void _loadProgress() async {
    int lvl = await StorageService.getUnlockedLevel();
    setState(() {
      unlockedLevel = lvl;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameTheme.bgPrimary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: GameTheme.textDark),
        title: Text('Select Level', style: GoogleFonts.poppins(color: GameTheme.textDark, fontWeight: FontWeight.bold)),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
        ),
        itemCount: GameTheme.totalLevels,
        itemBuilder: (context, index) {
          int level = index + 1;
          bool isUnlocked = level <= unlockedLevel;

          return GestureDetector(
            onTap: isUnlocked ? () {
              Navigator.pushReplacement(context, MaterialPageRoute(
                builder: (_) => GameScreen(levelNumber: level)
              ));
            } : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                color: isUnlocked ? GameTheme.blockSurface : GameTheme.bgSecondary,
                borderRadius: BorderRadius.circular(16),
                boxShadow: isUnlocked ? [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                ] : [],
              ),
              child: Center(
                child: isUnlocked 
                  ? Text('$level', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: GameTheme.upColor))
                  : const Icon(Icons.lock_rounded, color: GameTheme.textLight),
              ),
            ),
          );
        },
      ),
    );
  }
}
