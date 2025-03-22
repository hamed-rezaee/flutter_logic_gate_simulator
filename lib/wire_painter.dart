import 'package:flutter/material.dart';
import 'package:flutter_logic_gate_simulator/components/components.dart';

class WirePainter {
  static Path createWirePath({
    required Offset start,
    required Offset end,
    required List<Offset> segments,
  }) {
    final path = Path()..moveTo(start.dx, start.dy);

    if (segments.isEmpty) {
      final controlPointDistance = (end.dx - start.dx) / 2;
      final controlPoint1 = Offset(start.dx + controlPointDistance, start.dy);
      final controlPoint2 = Offset(end.dx - controlPointDistance, end.dy);

      path.cubicTo(
        controlPoint1.dx,
        controlPoint1.dy,
        controlPoint2.dx,
        controlPoint2.dy,
        end.dx,
        end.dy,
      );
    } else {
      for (final segment in segments) {
        path.lineTo(segment.dx, segment.dy);
      }
      path.lineTo(end.dx, end.dy);
    }

    return path;
  }

  static void drawDashedPath(Canvas canvas, Path path, Paint paint) {
    const dashWidth = 8;
    const dashSpace = 4;

    if (path.computeMetrics().isEmpty) {
      return;
    }

    final pathMetrics = path.computeMetrics().first;
    final pathLength = pathMetrics.length;

    var distance = 0.0;
    var drawLine = true;

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
  }

  static void drawWire({
    required Canvas canvas,
    required Wire wire,
    required Offset panOffset,
    required bool isSelected,
    Color? activeWireColor,
    Color? wireColor,
    Color? selectedWireColor,
  }) {
    activeWireColor ??= Colors.green;
    wireColor ??= Colors.grey[200]!;
    selectedWireColor ??= Colors.blueGrey;

    final path = createWirePath(
      start: wire.startPosition + panOffset,
      end: wire.endPosition + panOffset,
      segments: wire.segments.map((seg) => seg + panOffset).toList(),
    );

    final paint = Paint()
      ..color = wire.startPin.value ? activeWireColor : wireColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawPath(path, paint);

    if (isSelected) {
      final highlightPaint = Paint()
        ..color = selectedWireColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawPath(path, highlightPaint);
    }
  }

  static void drawTempWire({
    required Canvas canvas,
    required Offset start,
    required Offset end,
    required List<Offset> segments,
    required bool isActive,
    required bool isDashed,
    required Offset panOffset,
    Color? wireColor,
  }) {
    wireColor ??= Colors.grey[200]!;

    final adjustedStart = start + panOffset;
    final adjustedEnd = end + panOffset;
    final adjustedSegments = segments.map((seg) => seg + panOffset).toList();

    final path = createWirePath(
      start: adjustedStart,
      end: adjustedEnd,
      segments: adjustedSegments,
    );

    final paint = Paint()
      ..color = wireColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    isDashed
        ? drawDashedPath(canvas, path, paint)
        : canvas.drawPath(path, paint);
  }
}
