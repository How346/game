enum Direction { up, down, left, right }

class ArrowBlock {
  final String id;
  int x;
  int y;
  final Direction direction;
  bool isCleared;
  bool isHighlighted;
  double animOffsetX = 0;
  double animOffsetY = 0;

  ArrowBlock({
    required this.id, required this.x, required this.y, 
    required this.direction, this.isCleared = false, this.isHighlighted = false,
  });

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

  void triggerFlyOutAnimation() {
    isCleared = true;
    switch (direction) {
      case Direction.up: animOffsetY = -1000; break;
      case Direction.down: animOffsetY = 1000; break;
      case Direction.left: animOffsetX = -1000; break;
      case Direction.right: animOffsetX = 1000; break;
    }
  }

  ArrowBlock clone() {
    return ArrowBlock(
      id: id, x: x, y: y, direction: direction, isCleared: isCleared, isHighlighted: isHighlighted
    );
  }
}
