enum Direction { up, down, left, right }

class ArrowBlock {
  final String id;
  int x;
  int y;
  final Direction direction;
  bool isCleared;
  bool isHighlighted;

  ArrowBlock({
    required this.id,
    required this.x,
    required this.y,
    required this.direction,
    this.isCleared = false,
    this.isHighlighted = false,
  });

  // Calculate step offsets based on direction
  int get dx {
    switch (direction) {
      case Direction.left: return -1;
      case Direction.right: return 1;
      default: return 0;
    }
  }

  int get dy {
    switch (direction) {
      case Direction.up: return -1;
      case Direction.down: return 1;
      default: return 0;
    }
  }
}
