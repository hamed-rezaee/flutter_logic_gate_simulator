import 'dart:math';

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
    if (segments.length <= 1) return;

    const epsilon = 5.0;

    final points = [startPosition, ...segments, endPosition];
    final simplified = _ramerDouglasPeucker(points: points, epsilon: epsilon);

    segments
      ..clear()
      ..addAll(simplified.sublist(1, simplified.length - 1));
  }

  List<Offset> _ramerDouglasPeucker({
    required List<Offset> points,
    required double epsilon,
  }) {
    if (points.length < 3) return points;

    var maxDistance = 0.0;
    var index = 0;

    for (var i = 1; i < points.length - 1; i++) {
      final distance = _perpendicularDistance(
        point: points[i],
        lineStart: points.first,
        lineEnd: points.last,
      );
      if (distance > maxDistance) {
        index = i;
        maxDistance = distance;
      }
    }

    if (maxDistance > epsilon) {
      final left = _ramerDouglasPeucker(
        points: points.sublist(0, index + 1),
        epsilon: epsilon,
      );
      final right = _ramerDouglasPeucker(
        points: points.sublist(index),
        epsilon: epsilon,
      );

      return [...left.sublist(0, left.length - 1), ...right];
    } else {
      return [points.first, points.last];
    }
  }

  double _perpendicularDistance({
    required Offset point,
    required Offset lineStart,
    required Offset lineEnd,
  }) {
    final dx = lineEnd.dx - lineStart.dx;
    final dy = lineEnd.dy - lineStart.dy;

    if (dx == 0 && dy == 0) {
      return (point - lineStart).distance;
    }

    final numerator = ((dy * point.dx) -
            (dx * point.dy) +
            (lineEnd.dx * lineStart.dy) -
            (lineEnd.dy * lineStart.dx))
        .abs();
    final denominator = sqrt(dx * dx + dy * dy);

    return numerator / denominator;
  }
}
