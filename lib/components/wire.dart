import 'package:flutter/material.dart';
import 'package:flutter_logic_gate_simulator/components/pin.dart';

class Wire {
  const Wire({required this.startPin, required this.endPin});

  final Pin startPin;
  final Pin endPin;

  Offset get startPosition => startPin.position;

  Offset get endPosition => endPin.position;
}

class WirePainter extends CustomPainter {
  const WirePainter({
    required this.start,
    required this.end,
    required this.isActive,
  });

  final Offset start;
  final Offset end;
  final bool isActive;

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = isActive ? Colors.green : Colors.grey
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;

    final midX = (start.dx + end.dx) / 2;

    final path =
        Path()
          ..moveTo(start.dx, start.dy)
          ..cubicTo(midX, start.dy, midX, end.dy, end.dx, end.dy);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
