import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../widgets/clay_card.dart';
import 'game_screen.dart';

class LevelClearedScreen extends StatefulWidget {
  final int levelNumber;
  final int steps;
  const LevelClearedScreen({super.key, required this.levelNumber, required this.steps});

  @override
  State<LevelClearedScreen> createState() => _LevelClearedScreenState();
}

class _LevelClearedScreenState extends State<LevelClearedScreen> {
  bool isNewBest = false;
  int bestSteps = 0;

  @override
  void initState() {
    super.initState();
    _saveAndLoadProgress();
  }

  void _saveAndLoadProgress() async {
    StorageService.saveUnlockedLevel(widget.levelNumber + 1);
    bool newBest = await StorageService.saveBestSteps(widget.levelNumber, widget.steps);
    int best = await StorageService.getBestSteps(widget.levelNumber);
    setState(() {
      isNewBest = newBest;
      bestSteps = best;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Forcing Dark Mode colors for this specific screen per the image design
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
              
              // Stars
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.star, color: Colors.amber, size: 50),
                  Icon(Icons.star, color: Colors.amber, size: 60),
                  Icon(Icons.star, color: Colors.amber, size: 50),
                ],
              ),
              const SizedBox(height: 40),

              // Score Card
              ClayCard(
                color: const Color(0xFF1E2235),
                shadowColor: Colors.black45,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('🚶 Steps', style: TextStyle(color: Colors.white70, fontSize: 18)),
                        Text('${widget.steps}', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
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
                        decoration: BoxDecoration(color: Colors.green.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
                        child: const Text('🎉 NEW BEST!', style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
                      )
                    ]
                  ],
                ),
              ),
              const SizedBox(height: 50),

              GestureDetector(
                onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => GameScreen(levelNumber: widget.levelNumber + 1))),
                child: ClayCard(
                  color: Colors.blueAccent, shadowColor: Colors.black, borderRadius: 30,
                  child: const Center(child: Text('Next Level →', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))),
                ),
              ),
              const SizedBox(height: 15),
              TextButton(
                onPressed: () => Navigator.pop(context), // Goes back to Level Select
                child: const Text('Level Select', style: TextStyle(color: Colors.white54, fontSize: 18)),
              )
            ],
          ),
        ),
      ),
    );
  }
}
