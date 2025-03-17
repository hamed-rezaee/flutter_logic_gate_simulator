import 'package:flutter/material.dart';
import 'package:flutter_logic_gate_simulator/components/pin.dart';

class Wire extends StatelessWidget {
  const Wire({
    required this.startPosition,
    required this.endPosition,
    required this.isActive,
    required this.isSelected,
    this.onTap,
    this.isDashed = false,
    super.key,
  });

  final Offset startPosition;
  final Offset endPosition;
  final bool isActive;
  final bool isSelected;
  final bool isDashed;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    behavior: HitTestBehavior.translucent,
    onTap: onTap,
    child: CustomPaint(
      painter: _WirePainter(
        start: startPosition,
        end: endPosition,
        isActive: isActive,
        isSelected: isSelected,
        isDashed: isDashed,
      ),
    ),
  );
}

class _WirePainter extends CustomPainter {
  const _WirePainter({
    required this.start,
    required this.end,
    required this.isActive,
    required this.isSelected,
    this.isDashed = false,
  });

  final Offset start;
  final Offset end;
  final bool isActive;
  final bool isSelected;
  final bool isDashed;

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = isActive ? Colors.green : Colors.grey
          ..style = PaintingStyle.stroke
          ..strokeWidth = isSelected ? 4 : 2;

    final midX = (start.dx + end.dx) / 2;

    if (isDashed) {
      const dashWidth = 8;
      const dashSpace = 4;

      final path =
          Path()
            ..moveTo(start.dx, start.dy)
            ..cubicTo(midX, start.dy, midX, end.dy, end.dx, end.dy);

      var distance = 0.0;
      var drawLine = true;

      final pathMetrics = path.computeMetrics().first;
      final pathLength = pathMetrics.length;

      while (distance < pathLength) {
        final segmentLength = drawLine ? dashWidth : dashSpace;
        final nextDistance = distance + segmentLength;

        if (nextDistance > pathLength) {
          if (drawLine) {
            final start = pathMetrics.getTangentForOffset(distance)!.position;
            final end = pathMetrics.getTangentForOffset(pathLength)!.position;

            canvas.drawLine(start, end, paint);
          }

          break;
        }

        if (drawLine) {
          final start = pathMetrics.getTangentForOffset(distance)!.position;
          final end = pathMetrics.getTangentForOffset(nextDistance)!.position;

          canvas.drawLine(start, end, paint);
        }

        distance = nextDistance;
        drawLine = !drawLine;
      }
    } else {
      final path =
          Path()
            ..moveTo(start.dx, start.dy)
            ..cubicTo(midX, start.dy, midX, end.dy, end.dx, end.dy);

      canvas.drawPath(path, paint);
    }

    if (isSelected) {
      final highlightPaint =
          Paint()
            ..color = Colors.blue.withValues(alpha: 0.5)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 6;

      final path =
          Path()
            ..moveTo(start.dx, start.dy)
            ..cubicTo(midX, start.dy, midX, end.dy, end.dx, end.dy);

      canvas.drawPath(path, highlightPaint);
    }
  }

  @override
  bool shouldRepaint(_WirePainter oldDelegate) =>
      oldDelegate.start != start ||
      oldDelegate.end != end ||
      oldDelegate.isActive != isActive ||
      oldDelegate.isSelected != isSelected ||
      oldDelegate.isDashed != isDashed;
}

class WireModel {
  const WireModel({required this.startPin, required this.endPin});

  final Pin startPin;
  final Pin endPin;

  Offset get startPosition => startPin.position;

  Offset get endPosition => endPin.position;
}
