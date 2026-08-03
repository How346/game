import 'package:flutter/material.dart';

class ClayCard extends StatelessWidget {
  final Widget child;
  final Color color;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final bool isPressed;
  final Color shadowColor;

  const ClayCard({
    super.key,
    required this.child,
    required this.color,
    this.borderRadius = 20.0,
    this.padding = const EdgeInsets.all(16.0),
    this.isPressed = false,
    this.shadowColor = Colors.black26,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: isPressed ? [] : [
          BoxShadow(
            color: shadowColor,
            offset: const Offset(0, 6),
            blurRadius: 0,
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.2),
            offset: const Offset(0, -2),
            blurRadius: 2,
          )
        ],
      ),
      transform: isPressed ? Matrix4.translationValues(0, 4, 0) : Matrix4.identity(),
      child: child,
    );
  }
}
