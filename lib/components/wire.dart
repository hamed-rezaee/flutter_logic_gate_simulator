import 'package:flutter/material.dart';
import 'package:flutter_logic_gate_simulator/components/pin.dart';

class Wire extends StatelessWidget {
  const Wire({
    required this.startPosition,
    required this.endPosition,
    required this.isActive,
    required this.isSelected,
    this.wireSegments = const [],
    this.isDashed = false,
    this.onTap,
    super.key,
  });

  final Offset startPosition;
  final Offset endPosition;
  final bool isActive;
  final bool isSelected;
  final List<Offset> wireSegments;
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
            segments: wireSegments,
            isDashed: isDashed,
          ),
          size: Size(
            MediaQuery.of(context).size.width,
            MediaQuery.of(context).size.height,
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
    this.segments = const [],
    this.isDashed = false,
  });

  final Offset start;
  final Offset end;
  final List<Offset> segments;
  final bool isActive;
  final bool isSelected;
  final bool isDashed;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isActive ? Colors.green : Colors.grey[200]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = isSelected ? 4 : 2;

    final highlightPaint = Paint()
      ..color = Colors.blue.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;

    _drawCurvedWire(
      canvas: canvas,
      paint: paint,
      highlightPaint: highlightPaint,
    );
  }

  void _drawCurvedWire({
    required Canvas canvas,
    required Paint paint,
    required Paint highlightPaint,
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
      for (var i = 0; i < segments.length; i++) {
        final segment = segments[i];

        if (i == 0) {
          path.quadraticBezierTo(
            (start.dx + segment.dx) / 2,
            (start.dy + segment.dy) / 2,
            segment.dx,
            segment.dy,
          );
        }

        if (i < segments.length - 1) {
          final nextSegment = segments[i + 1];

          path.quadraticBezierTo(
            (segment.dx + nextSegment.dx) / 2,
            (segment.dy + nextSegment.dy) / 2,
            nextSegment.dx,
            nextSegment.dy,
          );
        } else {
          path.quadraticBezierTo(
            (segment.dx + end.dx) / 2,
            (segment.dy + end.dy) / 2,
            end.dx,
            end.dy,
          );
        }
      }
    }

    if (isDashed) {
      _drawDashedPath(canvas: canvas, path: path, paint: paint);
    } else {
      canvas.drawPath(path, paint);

      if (isSelected) {
        canvas.drawPath(path, highlightPaint);
      }
    }
  }

  void _drawDashedPath({
    required Canvas canvas,
    required Path path,
    required Paint paint,
  }) {
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

  bool _listEquals({
    required List<Offset> list1,
    required List<Offset> list2,
  }) {
    if (list1.length != list2.length) return false;

    for (var i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) return false;
    }

    return true;
  }

  @override
  bool shouldRepaint(_WirePainter oldDelegate) =>
      oldDelegate.start != start ||
      oldDelegate.end != end ||
      oldDelegate.isActive != isActive ||
      oldDelegate.isSelected != isSelected ||
      oldDelegate.isDashed != isDashed ||
      !_listEquals(list1: oldDelegate.segments, list2: segments);
}

class WireModel {
  WireModel({
    required this.startPin,
    required this.endPin,
    List<Offset>? segments,
  }) : segments = segments ?? [];

  final Pin startPin;
  final Pin endPin;
  final List<Offset> segments;

  Offset get startPosition => startPin.position;
  Offset get endPosition => endPin.position;

  List<Offset> generateDefaultSegments() {
    if (this.segments.isNotEmpty) {
      return this.segments;
    }

    final start = startPosition;
    final end = endPosition;
    final segments = <Offset>[];

    final midX = (start.dx + end.dx) / 2;

    segments
      ..add(Offset(midX, start.dy))
      ..add(Offset(midX, end.dy));

    return segments;
  }

  void autoRoute() {
    segments
      ..clear()
      ..addAll(generateDefaultSegments());
  }

  void addSegment(int index, Offset position) {
    if (segments.isEmpty) {
      segments.addAll(generateDefaultSegments());
    }

    if (index >= 0 && index <= segments.length) {
      segments.insert(index, position);
    }
  }

  void removeSegment(int index) {
    if (index >= 0 && index < segments.length) {
      segments.removeAt(index);
    }
  }

  void moveSegment(int index, Offset newPosition) {
    if (index >= 0 && index < segments.length) {
      segments[index] = newPosition;
    }
  }

  bool isPointNearWirePath({required Offset point, required double threshold}) {
    final allPoints = [startPosition, ...segments, endPosition];

    for (var i = 0; i < allPoints.length - 1; i++) {
      final start = allPoints[i];
      final end = allPoints[i + 1];
      final isPointNearLine = _isPointNearLine(
        point: point,
        lineStart: start,
        lineEnd: end,
        threshold: threshold,
      );

      if (isPointNearLine) {
        return true;
      }
    }

    return false;
  }

  bool _isPointNearLine({
    required Offset point,
    required Offset lineStart,
    required Offset lineEnd,
    required double threshold,
  }) {
    final lengthSquared = (lineEnd - lineStart).distanceSquared;

    if (lengthSquared == 0) {
      return (point - lineStart).distance <= threshold;
    }

    final t = ((point.dx - lineStart.dx) * (lineEnd.dx - lineStart.dx) +
            (point.dy - lineStart.dy) * (lineEnd.dy - lineStart.dy)) /
        lengthSquared;

    if (t < 0) {
      return (point - lineStart).distance <= threshold;
    } else if (t > 1) {
      return (point - lineEnd).distance <= threshold;
    }

    final closestPoint = Offset(
      lineStart.dx + t * (lineEnd.dx - lineStart.dx),
      lineStart.dy + t * (lineEnd.dy - lineStart.dy),
    );

    return (point - closestPoint).distance <= threshold;
  }
}
