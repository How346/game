import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/arrow_block.dart';
import '../models/level.dart';
import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/clay_card.dart';
import 'level_cleared_screen.dart';

class GameScreen extends StatefulWidget {
  final int levelNumber;
  const GameScreen({super.key, required this.levelNumber});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with SingleTickerProviderStateMixin {
  late Level currentLevel;
  late AnimationController _bgPulseController;
  int hearts = 3;
  int steps = 0;
  int perfectSteps = 0;

  @override
  void initState() {
    super.initState();
    // Gentle pulse for background dots
    _bgPulseController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _startLevel();
  }

  @override
  void dispose() {
    _bgPulseController.dispose();
    super.dispose();
  }

  void _startLevel() {
    setState(() {
      hearts = 3;
      steps = 0;
      currentLevel = Level.generateLevel(widget.levelNumber);
      perfectSteps = currentLevel.blocks.length;
    });
  }

  bool _canBlockClear(ArrowBlock block) {
    int currX = block.x + block.dx;
    int currY = block.y + block.dy;
    while (currX >= 0 && currX < currentLevel.gridWidth && currY >= 0 && currY < currentLevel.gridHeight) {
      if (currentLevel.blocks.any((b) => !b.isCleared && b.x == currX && b.y == currY)) return false;
      currX += block.dx;
      currY += block.dy;
    }
    return true;
  }

  // --- NEW: Hint Logic ---
  void _triggerHint() {
    for (var block in currentLevel.blocks) {
      if (!block.isCleared && _canBlockClear(block)) {
        setState(() => block.isHighlighted = true);
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (mounted) setState(() => block.isHighlighted = false);
        });
        break; // Only highlight one block
      }
    }
  }

  void _onBlockTapped(ArrowBlock block) {
    if (block.isCleared) return;
    
    final settings = context.read<SettingsProvider>();
    settings.triggerHaptic();

    setState(() { steps++; }); 

    if (_canBlockClear(block)) {
      setState(() {
        block.triggerFlyOutAnimation(); 
      });

      Future.delayed(const Duration(milliseconds: 350), () {
        if (!mounted) return;
        
        if (currentLevel.blocks.every((b) => b.isCleared)) {
          Navigator.pushReplacement(context, MaterialPageRoute(
            builder: (_) => LevelClearedScreen(
              levelNumber: widget.levelNumber, 
              steps: steps,
              perfectSteps: perfectSteps,
            )
          ));
        }
      });
    } else {
      setState(() => hearts--);
      if (hearts <= 0) _startLevel(); 
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<SettingsProvider>().isDarkMode;
    final textColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(textColor),
            Expanded(child: Center(child: _buildGameBoard())),
            _buildBottomControls(textColor),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(Color textColor) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios_rounded, color: textColor),
            onPressed: () => Navigator.pop(context),
          ),
          Row(
            children: List.generate(3, (index) => Icon(
              index < hearts ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: Colors.pink, size: 28,
            )),
          ),
          ClayCard(
            color: Colors.white, shadowColor: Colors.black12, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text('Level ${widget.levelNumber}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
          )
        ],
      ),
    );
  }

  Widget _buildGameBoard() {
    double boardSize = MediaQuery.of(context).size.width * 0.85;
    double blockSize = boardSize / currentLevel.gridWidth;

    return SizedBox(
      width: boardSize, height: boardSize,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // --- NEW: Animated Background Dots ---
          AnimatedBuilder(
            animation: _bgPulseController,
            builder: (context, child) {
              return Stack(
                children: [
                  for (int y = 0; y < currentLevel.gridHeight; y++)
                    for (int x = 0; x < currentLevel.gridWidth; x++)
                      Positioned(
                        left: x * blockSize + (blockSize / 2) - 4,
                        top: y * blockSize + (blockSize / 2) - 4,
                        child: Transform.scale(
                          scale: 0.8 + (_bgPulseController.value * 0.4), // Pulse size
                          child: Container(
                            width: 8, height: 8, 
                            decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.2 + (_bgPulseController.value * 0.2)), shape: BoxShape.circle)
                          ),
                        ),
                      ),
                ],
              );
            }
          ),
          
          for (var block in currentLevel.blocks)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              left: (block.x * blockSize) + block.animOffsetX,
              top: (block.y * blockSize) + block.animOffsetY,
              width: blockSize,
              height: blockSize,
              // Applies smooth fade and shrink when cleared
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: block.opacity,
                child: AnimatedScale(
                  duration: const Duration(milliseconds: 300),
                  scale: block.scale,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: () => _onBlockTapped(block),
                      child: ClayCard(
                        // Highlight overrides color if hint is triggered
                        color: block.isHighlighted ? Colors.orangeAccent : _getBlockColor(block.direction), 
                        shadowColor: Colors.black, borderRadius: 16,
                        child: Icon(_getArrowIcon(block.direction), color: Colors.white, size: 32),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomControls(Color textColor) {
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          TextButton.icon(
            icon: const Icon(Icons.lightbulb, color: Colors.orange), label: Text('Hint', style: TextStyle(color: textColor, fontSize: 18)),
            onPressed: _triggerHint, 
          ),
          TextButton.icon(
            icon: const Icon(Icons.refresh, color: Colors.blue), label: Text('Restart', style: TextStyle(color: textColor, fontSize: 18)),
            onPressed: _startLevel,
          ),
        ],
      ),
    );
  }

  Color _getBlockColor(Direction dir) {
    switch (dir) {
      case Direction.up: return AppTheme.arrowUp;
      case Direction.down: return AppTheme.arrowDown;
      case Direction.left: return AppTheme.arrowLeft;
      case Direction.right: return AppTheme.arrowRight;
    }
  }

  IconData _getArrowIcon(Direction dir) {
    switch (dir) {
      case Direction.up: return Icons.keyboard_arrow_up_rounded;
      case Direction.down: return Icons.keyboard_arrow_down_rounded;
      case Direction.left: return Icons.keyboard_arrow_left_rounded;
      case Direction.right: return Icons.keyboard_arrow_right_rounded;
    }
  }
}
