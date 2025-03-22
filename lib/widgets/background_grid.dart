import 'package:flutter/material.dart';

class BackgroundGrid extends StatelessWidget {
  const BackgroundGrid({required this.panOffset, super.key});

  final Offset panOffset;

  @override
  Widget build(BuildContext context) => CustomPaint(
        size: Size.infinite,
        painter: _GridPainter(panOffset: panOffset),
      );
}

class _GridPainter extends CustomPainter {
  const _GridPainter({required this.panOffset});

  final Offset panOffset;

  static const gridSize = 20;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.4)
      ..strokeWidth = 0.5;

    final xOffset = panOffset.dx % gridSize;
    final yOffset = panOffset.dy % gridSize;

    for (var y = yOffset; y <= size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    for (var x = xOffset; x <= size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) =>
      oldDelegate.panOffset != panOffset;
}
