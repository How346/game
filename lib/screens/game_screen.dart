import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/game_theme.dart';
import '../models/arrow_block.dart';
import '../models/level.dart';
import '../services/storage_service.dart';
import 'level_selection_screen.dart';

class GameScreen extends StatefulWidget {
  final int levelNumber;
  const GameScreen({super.key, required this.levelNumber});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late Level currentLevel;
  int hearts = GameTheme.maxHearts;
  bool isPaused = false;

  @override
  void initState() {
    super.initState();
    _startLevel(widget.levelNumber);
  }

  void _startLevel(int level) {
    setState(() {
      hearts = GameTheme.maxHearts;
      currentLevel = Level.generateLevel(level);
    });
  }

  bool _canBlockClear(ArrowBlock block) {
    int currX = block.x + block.dx;
    int currY = block.y + block.dy;

    while (currX >= 0 && currX < currentLevel.gridWidth && currY >= 0 && currY < currentLevel.gridHeight) {
      bool isBlocked = currentLevel.blocks.any((b) => !b.isCleared && b.x == currX && b.y == currY);
      if (isBlocked) return false;
      currX += block.dx;
      currY += block.dy;
    }
    return true;
  }

  void _onBlockTapped(ArrowBlock block) {
    if (block.isCleared || isPaused) return;

    if (_canBlockClear(block)) {
      setState(() => block.isCleared = true);

      if (currentLevel.blocks.every((b) => b.isCleared)) {
        _onLevelCompleted();
      }
    } else {
      setState(() => hearts--);
      if (hearts <= 0) _showDialog('Failed!', GameTheme.danger, () => _startLevel(currentLevel.levelNumber));
    }
  }

  void _triggerHint() {
    for (var block in currentLevel.blocks) {
      if (!block.isCleared && _canBlockClear(block)) {
        setState(() => block.isHighlighted = true);
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) setState(() => block.isHighlighted = false);
        });
        break;
      }
    }
  }

  void _onLevelCompleted() {
    StorageService.saveUnlockedLevel(currentLevel.levelNumber + 1);
    _showDialog('Cleared!', GameTheme.success, () {
      if (currentLevel.levelNumber < GameTheme.totalLevels) {
        _startLevel(currentLevel.levelNumber + 1);
      } else {
        Navigator.pop(context);
      }
    });
  }

  void _showDialog(String title, Color color, VoidCallback onAction) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: GameTheme.blockSurface,
        title: Text(title, textAlign: TextAlign.center, style: GoogleFonts.poppins(color: color, fontWeight: FontWeight.bold, fontSize: 24)),
        content: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            padding: const EdgeInsets.symmetric(vertical: 12)
          ),
          onPressed: () {
            Navigator.pop(context);
            onAction();
          },
          child: Text(title == 'Failed!' ? 'Retry' : 'Next', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  IconData _getArrowIcon(Direction dir) {
    switch (dir) {
      case Direction.up: return Icons.keyboard_arrow_up_rounded;
      case Direction.down: return Icons.keyboard_arrow_down_rounded;
      case Direction.left: return Icons.keyboard_arrow_left_rounded;
      case Direction.right: return Icons.keyboard_arrow_right_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameTheme.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(child: Center(child: _buildGameBoard())),
            _buildBottomControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: GameTheme.textDark),
            onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LevelSelectionScreen())),
          ),
          Text('Level ${currentLevel.levelNumber}', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w800, color: GameTheme.textDark)),
          Row(
            children: List.generate(GameTheme.maxHearts, (index) => Icon(
              index < hearts ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: GameTheme.danger, size: 28,
            )),
          )
        ],
      ),
    );
  }

  Widget _buildGameBoard() {
    int w = currentLevel.gridWidth;
    double size = MediaQuery.of(context).size.width * 0.9;

    return Container(
      width: size, height: size,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: GameTheme.bgSecondary,
        borderRadius: BorderRadius.circular(30),
      ),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: w * w,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: w, crossAxisSpacing: 10, mainAxisSpacing: 10,
        ),
        itemBuilder: (context, index) {
          int x = index % w;
          int y = index ~/ w;
          var blocks = currentLevel.blocks.where((b) => b.x == x && b.y == y);
          
          if (blocks.isEmpty || blocks.first.isCleared) return const SizedBox.shrink();

          ArrowBlock block = blocks.first;
          return GestureDetector(
            onTap: () => _onBlockTapped(block),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: block.isHighlighted ? GameTheme.highlightColor : GameTheme.blockSurface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: block.color.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))
                ],
              ),
              child: Center(
                child: Icon(_getArrowIcon(block.direction), color: block.color, size: 40),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomControls() {
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          FloatingActionButton.extended(
            heroTag: 'hint',
            backgroundColor: GameTheme.upColor,
            elevation: 0,
            icon: const Icon(Icons.lightbulb_outline_rounded, color: Colors.white),
            label: Text('Hint', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
            onPressed: _triggerHint,
          ),
          FloatingActionButton(
            heroTag: 'restart',
            backgroundColor: GameTheme.blockSurface,
            elevation: 0,
            onPressed: () => _startLevel(currentLevel.levelNumber),
            child: const Icon(Icons.refresh_rounded, color: GameTheme.textDark),
          ),
        ],
      ),
    );
  }
}
