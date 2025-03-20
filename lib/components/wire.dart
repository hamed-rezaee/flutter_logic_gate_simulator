import 'package:flutter/material.dart';
import 'package:flutter_logic_gate_simulator/components/pin.dart';

class Wire {
  Wire({
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

  void optimize() {
    // TODO: Implement this method to optimize the wire path
  }
}
