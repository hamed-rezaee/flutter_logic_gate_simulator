import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_logic_gate_simulator/simulator_manager.dart';

class CanvasBoundsCalculator {
  static (Rect, double) calculateContentBounds({
    required SimulatorManager simulatorManager,
    required Size viewportSize,
  }) {
    if (simulatorManager.components.isEmpty) {
      return (Rect.zero, 0);
    }

    var minX = double.infinity;
    var minY = double.infinity;
    var maxX = double.negativeInfinity;
    var maxY = double.negativeInfinity;

    for (final component in simulatorManager.components) {
      final pos = component.position;
      final componentSize = component.size;

      minX = math.min(minX, pos.dx);
      minY = math.min(minY, pos.dy);
      maxX = math.max(maxX, pos.dx + componentSize.width);
      maxY = math.max(maxY, pos.dy + componentSize.height);
    }

    for (final wire in simulatorManager.wires) {
      final allPoints = [
        wire.startPosition,
        ...wire.segments,
        wire.endPosition,
      ];

      for (final point in allPoints) {
        minX = math.min(minX, point.dx);
        minY = math.min(minY, point.dy);
        maxX = math.max(maxX, point.dx);
        maxY = math.max(maxY, point.dy);
      }
    }

    const padding = 50.0;
    minX -= padding;
    minY -= padding;
    maxX += padding;
    maxY += padding;

    final contentRect = Rect.fromLTRB(minX, minY, maxX, maxY);
    final contentWidth = maxX - minX;
    final contentHeight = maxY - minY;

    final scaleX = viewportSize.width / contentWidth;
    final scaleY = viewportSize.height / contentHeight;

    final scale = math.min(scaleX, scaleY);

    return (contentRect, scale);
  }
}
