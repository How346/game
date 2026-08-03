import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../widgets/clay_card.dart';
import 'game_screen.dart';

class LevelClearedScreen extends StatefulWidget {
  final int levelNumber;
  final int steps;
  final int perfectSteps;

  const LevelClearedScreen({
    super.key, 
    required this.levelNumber, 
    required this.steps,
    required this.perfectSteps,
  });

  @override
  State<LevelClearedScreen> createState() => _LevelClearedScreenState();
}

class _LevelClearedScreenState extends State<LevelClearedScreen> {
  bool isNewBest = false;
  int bestSteps = 0;
  int starsEarned = 0;

  @override
  void initState() {
    super.initState();
    _calculateAndSaveProgress();
  }

  void _calculateAndSaveProgress() async {
    if (widget.steps == widget.perfectSteps) {
      starsEarned = 3; 
    } else if (widget.steps <= widget.perfectSteps + 2) {
      starsEarned = 2; 
    } else {
      starsEarned = 1; 
    }

    StorageService.saveUnlockedLevel(widget.levelNumber + 1);
    StorageService.saveStars(widget.levelNumber, starsEarned);
    bool newBest = await StorageService.saveBestSteps(widget.levelNumber, widget.steps);
    int best = await StorageService.getBestSteps(widget.levelNumber);
    
    setState(() {
      isNewBest = newBest;
      bestSteps = best;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111424), 
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('LEVEL CLEARED!', style: TextStyle(color: Colors.greenAccent, fontSize: 32, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text('Level ${widget.levelNumber}', style: const TextStyle(color: Colors.white70, fontSize: 18)),
              const SizedBox(height: 30),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.star, color: starsEarned >= 1 ? Colors.amber : Colors.white24, size: 50),
                  Icon(Icons.star, color: starsEarned >= 3 ? Colors.amber : Colors.white24, size: 60), 
                  Icon(Icons.star, color: starsEarned >= 2 ? Colors.amber : Colors.white24, size: 50),
                ],
              ),
              const SizedBox(height: 40),

              ClayCard(
                color: const Color(0xFF1E2235),
                shadowColor: Colors.black45,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('🚶 Steps', style: TextStyle(color: Colors.white70, fontSize: 18)),
                        Text('${widget.steps} / ${widget.perfectSteps}', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const Divider(color: Colors.white24, height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('🏆 Best Score', style: TextStyle(color: Colors.white70, fontSize: 18)),
                        Text('$bestSteps steps', style: const TextStyle(color: Colors.amber, fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    if (isNewBest) ...[
                      const SizedBox(height: 15),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        // FIX: Updated withOpacity to withValues
                        decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)),
                        child: const Text('🎉 NEW BEST!', style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
                      )
                    ]
                  ],
                ),
              ),
              const SizedBox(height: 50),

              GestureDetector(
                onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => GameScreen(levelNumber: widget.levelNumber + 1))),
                // FIX: Added const keyword here
                child: const ClayCard(
                  color: Colors.blueAccent, shadowColor: Colors.black, borderRadius: 30,
                  child: Center(child: Text('Next Level →', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))),
                ),
              ),
              const SizedBox(height: 15),
              TextButton(
                onPressed: () => Navigator.pop(context), 
                child: const Text('Level Select', style: TextStyle(color: Colors.white54, fontSize: 18)),
              )
            ],
          ),
        ),
      ),
    );
  }
}
