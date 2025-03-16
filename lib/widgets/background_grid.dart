import 'dart:ui';

import 'package:flutter/material.dart';

class BackgroundGrid extends StatelessWidget {
  const BackgroundGrid({super.key});

  @override
  Widget build(BuildContext context) =>
      const CustomPaint(size: Size.infinite, painter: _GridPainter());
}

class _GridPainter extends CustomPainter {
  const _GridPainter();

  static const gridSize = 20;

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.grey.withValues(alpha: 0.3)
          ..strokeWidth = 0.5;

    for (double i = 0; i < size.width; i += gridSize) {
      for (double j = 0; j < size.height; j += gridSize) {
        final points = [
          Offset(i, j),
          Offset(i + gridSize, j),
          Offset(i, j),
          Offset(i, j + gridSize),
        ];

        canvas.drawPoints(PointMode.lines, points, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
