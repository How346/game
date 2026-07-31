import 'package:flutter/material.dart';
import '../config/game_theme.dart';

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

  Color get color {
    switch (direction) {
      case Direction.up: return GameTheme.upColor;
      case Direction.down: return GameTheme.downColor;
      case Direction.left: return GameTheme.leftColor;
      case Direction.right: return GameTheme.rightColor;
    }
  }

  // Clone for the solver
  ArrowBlock clone() {
    return ArrowBlock(
      id: id, x: x, y: y, direction: direction, isCleared: isCleared,
    );
  }
}
