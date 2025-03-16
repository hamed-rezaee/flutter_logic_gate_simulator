import 'package:flutter/material.dart';
import 'package:flutter_logic_gate_simulator/components/pin.dart';

class Wire extends StatelessWidget {
  const Wire({
    required this.startPosition,
    required this.endPosition,
    required this.isActive,
    super.key,
  });

  final Offset startPosition;
  final Offset endPosition;
  final bool isActive;

  @override
  Widget build(BuildContext context) => CustomPaint(
    size: Size.infinite,
    painter: _WirePainter(
      start: startPosition,
      end: endPosition,
      isActive: isActive,
    ),
  );
}

class _WirePainter extends CustomPainter {
  const _WirePainter({
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

class WireModel {
  const WireModel({required this.startPin, required this.endPin});

  final Pin startPin;
  final Pin endPin;

  Offset get startPosition => startPin.position;

  Offset get endPosition => endPin.position;
}
