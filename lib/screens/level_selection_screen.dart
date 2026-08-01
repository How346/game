import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../services/storage_service.dart';
import '../widgets/clay_card.dart';
import 'game_screen.dart';

class LevelSelectionScreen extends StatefulWidget {
  const LevelSelectionScreen({super.key});

  @override
  State<LevelSelectionScreen> createState() => _LevelSelectionScreenState();
}

class _LevelSelectionScreenState extends State<LevelSelectionScreen> {
  int unlockedLevel = 1;
  Map<int, int> levelStars = {}; // Store stars for each level

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  void _loadProgress() async {
    int lvl = await StorageService.getUnlockedLevel();
    Map<int, int> stars = {};
    
    // Load stars for all unlocked levels
    for (int i = 1; i <= lvl; i++) {
      stars[i] = await StorageService.getStars(i);
    }

    setState(() {
      unlockedLevel = lvl;
      levelStars = stars;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<SettingsProvider>().isDarkMode;
    final textColor = isDark ? Colors.white : Colors.black;
    final cardColor = isDark ? const Color(0xFF1E2235) : Colors.white;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        title: Text('Select Level', style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 24)),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
        ),
        itemCount: 100, // Total levels
        itemBuilder: (context, index) {
          int level = index + 1;
          bool isUnlocked = level <= unlockedLevel;
          int stars = levelStars[level] ?? 0;

          return GestureDetector(
            onTap: isUnlocked ? () {
              Navigator.push(context, MaterialPageRoute(
                builder: (_) => GameScreen(levelNumber: level)
              )).then((_) => _loadProgress()); // Refresh when returning
            } : null,
            child: ClayCard(
              color: isUnlocked ? cardColor : (isDark ? Colors.white10 : Colors.black12),
              shadowColor: isDark ? Colors.black54 : Colors.black12,
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  isUnlocked 
                    ? Text('$level', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor))
                    : Icon(Icons.lock_rounded, color: textColor.withOpacity(0.5)),
                  
                  if (isUnlocked)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (starIndex) => Icon(
                        Icons.star,
                        size: 10,
                        color: starIndex < stars ? Colors.amber : Colors.grey.withOpacity(0.3),
                      )),
                    )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
