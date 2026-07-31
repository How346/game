import 'package:flutter/material.dart';
import '../config/game_config.dart';
import '../models/arrow_block.dart';
import '../models/level.dart';
import '../services/storage_service.dart';
import '../widgets/glass_card.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late Level currentLevel;
  int levelNum = 1;
  int hearts = GameConfig.maxHearts;
  int score = 0;
  bool soundEnabled = true;
  bool isPaused = false;

  @override
  void initState() {
    super.initState();
    _loadGameData();
  }

  void _loadGameData() async {
    int savedLevel = await StorageService.getCurrentLevel();
    bool sound = await StorageService.isSoundEnabled();
    setState(() {
      levelNum = savedLevel;
      soundEnabled = sound;
      _startLevel(levelNum);
    });
  }

  void _startLevel(int level) {
    setState(() {
      levelNum = level;
      hearts = GameConfig.maxHearts;
      currentLevel = Level.generateLevel(levelNum);
    });
  }

  void _onBlockTapped(ArrowBlock block) {
    if (block.isCleared || isPaused) return;

    if (_canBlockClear(block)) {
      setState(() {
        block.isCleared = true;
        score += 100;
      });

      if (currentLevel.blocks.every((b) => b.isCleared)) {
        _onLevelCompleted();
      }
    } else {
      setState(() {
        hearts--;
      });

      if (hearts <= 0) {
        _showGameOverDialog();
      }
    }
  }

  bool _canBlockClear(ArrowBlock block) {
    int currX = block.x + block.dx;
    int currY = block.y + block.dy;

    while (currX >= 0 &&
        currX < currentLevel.gridWidth &&
        currY >= 0 &&
        currY < currentLevel.gridHeight) {
      bool isBlocked = currentLevel.blocks.any(
          (b) => !b.isCleared && b.x == currX && b.y == currY);
      if (isBlocked) return false;

      currX += block.dx;
      currY += block.dy;
    }
    return true;
  }

  void _triggerHint() {
    // Instantly find and highlight a block that can be cleared
    for (var block in currentLevel.blocks) {
      if (!block.isCleared && _canBlockClear(block)) {
        setState(() {
          block.isHighlighted = true;
        });
        
        // Remove highlight after 2 seconds
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() {
              block.isHighlighted = false;
            });
          }
        });
        break;
      }
    }
  }

  void _onLevelCompleted() {
    StorageService.saveCurrentLevel(levelNum + 1);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.transparent,
        content: GlassCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('LEVEL CLEARED!',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              const SizedBox(height: 10),
              Text('Score: $score', style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: GameConfig.primaryColor),
                onPressed: () {
                  Navigator.pop(context);
                  _startLevel(levelNum + 1); // Move directly to next level
                },
                child: const Text('Next Level',
                    style: TextStyle(color: Colors.white)),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.transparent,
        content: GlassCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('LEVEL FAILED',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.redAccent)),
              const SizedBox(height: 10),
              const Text('You ran out of hearts!',
                  style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: GameConfig.primaryColor),
                onPressed: () {
                  Navigator.pop(context);
                  _startLevel(levelNum); // Restart current level
                },
                child: const Text('Try Again',
                    style: TextStyle(color: Colors.white)),
              )
            ],
          ),
        ),
      ),
    );
  }

  IconData _getArrowIcon(Direction dir) {
    switch (dir) {
      case Direction.up: return Icons.arrow_upward_rounded;
      case Direction.down: return Icons.arrow_downward_rounded;
      case Direction.left: return Icons.arrow_back_rounded;
      case Direction.right: return Icons.arrow_forward_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [GameConfig.bgGradientStart, GameConfig.bgGradientEnd],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildTopStatusBar(),
              Expanded(child: Center(child: _buildGameBoard())),
              _buildControlBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopStatusBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: List.generate(
                GameConfig.maxHearts,
                (index) => Icon(
                  index < hearts ? Icons.favorite : Icons.favorite_border,
                  color: Colors.redAccent,
                ),
              ),
            ),
            Text('Level $levelNum',
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            IconButton(
              icon: Icon(soundEnabled ? Icons.volume_up : Icons.volume_off,
                  color: Colors.white),
              onPressed: () {
                setState(() {
                  soundEnabled = !soundEnabled;
                  StorageService.setSoundEnabled(soundEnabled);
                });
              },
            )
          ],
        ),
      ),
    );
  }

  Widget _buildGameBoard() {
    // Only build the grid if the level data is ready
    if (levelNum == 0) return const CircularProgressIndicator();

    int gridWidth = currentLevel.gridWidth;
    double size = MediaQuery.of(context).size.width * 0.85;

    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white12),
      ),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: gridWidth * gridWidth,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: gridWidth,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemBuilder: (context, index) {
          int x = index % gridWidth;
          int y = index ~/ gridWidth;

          var blockList = currentLevel.blocks.where((b) => b.x == x && b.y == y);
          if (blockList.isEmpty || blockList.first.isCleared) {
            return const SizedBox.shrink();
          }

          ArrowBlock block = blockList.first;
          return GestureDetector(
            onTap: () => _onBlockTapped(block),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: block.isHighlighted
                    ? GameConfig.highlightColor
                    : GameConfig.blockColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black45,
                    offset: Offset(0, 4),
                    blurRadius: 6,
                  )
                ],
              ),
              child: Center(
                child: Icon(
                  _getArrowIcon(block.direction),
                  color: block.isHighlighted ? Colors.black : Colors.white,
                  size: 32,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildControlBar() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: GameConfig.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
            ),
            onPressed: _triggerHint,
            icon: const Icon(Icons.lightbulb_outline, color: Colors.white),
            label: const Text('Hint',
                style: TextStyle(color: Colors.white, fontSize: 16)),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white, size: 30),
            onPressed: () => _startLevel(levelNum),
          ),
        ],
      ),
    );
  }
}
