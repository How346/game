import 'dart:math';
import 'arrow_block.dart';

class Level {
  final int levelNumber;
  final int gridWidth;
  final int gridHeight;
  final List<ArrowBlock> blocks;

  Level({
    required this.levelNumber,
    required this.gridWidth,
    required this.gridHeight,
    required this.blocks,
  });

  static Level generateLevel(int levelNum) {
    int size = levelNum <= 10 ? 3 : (levelNum <= 40 ? 4 : 5);
    int count = min(size * size, 3 + (levelNum ~/ 1.5));
    Random rand = Random(levelNum * 999);
    List<ArrowBlock> validBlocks = [];
    
    while (true) {
      validBlocks = _tryGenerateBoard(size, count, rand);
      if (_isSolvable(validBlocks, size, size)) break;
    }

    return Level(levelNumber: levelNum, gridWidth: size, gridHeight: size, blocks: validBlocks);
  }

  static List<ArrowBlock> _tryGenerateBoard(int size, int count, Random rand) {
    List<ArrowBlock> blocks = [];
    Set<String> positions = {};
    for (int i = 0; i < count; i++) {
      int x, y;
      do {
        x = rand.nextInt(size);
        y = rand.nextInt(size);
      } while (positions.contains('$x,$y'));

      positions.add('$x,$y');
      Direction dir = Direction.values[rand.nextInt(Direction.values.length)];
      blocks.add(ArrowBlock(id: 'block_$i', x: x, y: y, direction: dir));
    }
    return blocks;
  }

  static bool _isSolvable(List<ArrowBlock> initialBlocks, int width, int height) {
    List<ArrowBlock> remaining = initialBlocks.map((b) => b.clone()).toList();
    bool madeProgress = true;
    while (madeProgress && remaining.isNotEmpty) {
      madeProgress = false;
      for (int i = 0; i < remaining.length; i++) {
        if (_canClear(remaining[i], remaining, width, height)) {
          remaining.removeAt(i);
          madeProgress = true;
          break; 
        }
      }
    }
    return remaining.isEmpty;
  }

  static bool _canClear(ArrowBlock block, List<ArrowBlock> allBlocks, int w, int h) {
    int currX = block.x + block.dx;
    int currY = block.y + block.dy;
    while (currX >= 0 && currX < w && currY >= 0 && currY < h) {
      bool isBlocked = allBlocks.any((b) => b.x == currX && b.y == currY);
      if (isBlocked) return false;
      currX += block.dx;
      currY += block.dy;
    }
    return true;
  }
}
