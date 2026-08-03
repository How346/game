enum Direction { up, down, left, right }

class ArrowBlock {
  final String id;
  int x;
  int y;
  final Direction direction;
  bool isCleared;
  bool isHighlighted;
  
  // Animation and interaction states
  double animOffsetX = 0;
  double animOffsetY = 0;
  double opacity = 1.0;
  bool isPressed = false; // NEW: Tracks if the user's finger is on the block

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

  // NEW: Snappy Projectile Animation
  void triggerFlyOutAnimation() {
    isCleared = true;
    opacity = 0.0; // Fade out during flight
    
    // Shoot completely off the screen rapidly (800 pixels)
    int distance = 800; 
    switch (direction) {
      case Direction.up: animOffsetY = -distance.toDouble(); break;
      case Direction.down: animOffsetY = distance.toDouble(); break;
      case Direction.left: animOffsetX = -distance.toDouble(); break;
      case Direction.right: animOffsetX = distance.toDouble(); break;
    }
  }

  ArrowBlock clone() {
    return ArrowBlock(
      id: id, x: x, y: y, direction: direction, isCleared: isCleared, isHighlighted: isHighlighted
    );
  }
}
