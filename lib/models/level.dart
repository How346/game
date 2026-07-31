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
    // Increase grid size based on level progression
    int size = levelNum < 5 ? 3 : (levelNum < 20 ? 4 : 5);
    List<ArrowBlock> blocks = [];
    Random rand = Random(levelNum * 42); // Seeded for consistent levels

    // Increase block count as levels progress
    int count = min(size * size - 1, 4 + (levelNum ~/ 3));
    Set<String> positions = {};

    for (int i = 0; i < count; i++) {
      int x, y;
      do {
        x = rand.nextInt(size);
        y = rand.nextInt(size);
      } while (positions.contains('$x,$y'));

      positions.add('$x,$y');
      Direction dir = Direction.values[rand.nextInt(Direction.values.length)];

      blocks.add(ArrowBlock(
        id: 'block_${levelNum}_$i',
        x: x,
        y: y,
        direction: dir,
      ));
    }

    return Level(
      levelNumber: levelNum,
      gridWidth: size,
      gridHeight: size,
      blocks: blocks,
    );
  }
}
