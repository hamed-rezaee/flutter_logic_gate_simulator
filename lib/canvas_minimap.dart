import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_logic_gate_simulator/simulator_manager.dart';

class CanvasMinimap extends StatelessWidget {
  const CanvasMinimap({
    required this.simulatorManager,
    required this.viewportSize,
    required this.panOffset,
    required this.onPositionChanged,
    this.size = const Size(250, 150),
    this.backgroundColor = Colors.black,
    this.borderColor = Colors.grey,
    this.componentColor = Colors.white70,
    this.wireColor = Colors.grey,
    this.activeWireColor = Colors.green,
    this.viewportColor = Colors.blueGrey,
    this.textColor = Colors.white,
    super.key,
  });

  final SimulatorManager simulatorManager;
  final Size viewportSize;
  final Offset panOffset;
  final void Function(Offset) onPositionChanged;
  final Size size;
  final Color backgroundColor;
  final Color borderColor;
  final Color componentColor;
  final Color wireColor;
  final Color activeWireColor;
  final Color viewportColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    final (Rect contentBounds, double scale) = _calculateContentBounds();

    return Container(
      width: size.width,
      height: size.height,
      decoration: BoxDecoration(
        color: backgroundColor.withValues(alpha: 0.7),
        border: Border.all(color: borderColor),
      ),
      child: GestureDetector(
        onTapDown: (details) =>
            _handleTap(details.localPosition, contentBounds, scale),
        onPanUpdate: (details) =>
            _handleDrag(details.localPosition, contentBounds, scale),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: CustomPaint(
            size: size,
            painter: _MinimapPainter(
              simulatorManager: simulatorManager,
              viewportSize: viewportSize,
              panOffset: panOffset,
              contentBounds: contentBounds,
              scale: scale,
              componentColor: componentColor,
              wireColor: wireColor,
              activeWireColor: activeWireColor,
              viewportColor: viewportColor,
              textColor: textColor,
            ),
          ),
        ),
      ),
    );
  }

  (Rect, double) _calculateContentBounds() {
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

    final scaleX = size.width / contentWidth;
    final scaleY = size.height / contentHeight;

    final scale = math.min(scaleX, scaleY);

    return (contentRect, scale);
  }

  void _handleTap(Offset position, Rect contentBounds, double scale) =>
      _updatePanOffset(position, contentBounds, scale);

  void _handleDrag(Offset position, Rect contentBounds, double scale) =>
      _updatePanOffset(position, contentBounds, scale);

  void _updatePanOffset(Offset position, Rect contentBounds, double scale) {
    final canvasX = contentBounds.left + position.dx / scale;
    final canvasY = contentBounds.top + position.dy / scale;

    final newPanX = -canvasX + viewportSize.width / 2;
    final newPanY = -canvasY + viewportSize.height / 2;

    onPositionChanged(Offset(newPanX, newPanY));
  }
}

class _MinimapPainter extends CustomPainter {
  const _MinimapPainter({
    required this.simulatorManager,
    required this.viewportSize,
    required this.panOffset,
    required this.contentBounds,
    required this.scale,
    required this.componentColor,
    required this.wireColor,
    required this.activeWireColor,
    required this.viewportColor,
    required this.textColor,
  });

  final SimulatorManager simulatorManager;
  final Size viewportSize;
  final Offset panOffset;
  final Rect contentBounds;
  final double scale;
  final Color componentColor;
  final Color wireColor;
  final Color activeWireColor;
  final Color viewportColor;
  final Color textColor;

  @override
  void paint(Canvas canvas, Size size) {
    _drawWires(canvas);
    _drawComponents(canvas);
    _drawViewport(canvas);
  }

  void _drawComponents(Canvas canvas) {
    final paint = Paint()
      ..color = componentColor
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = componentColor.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final textStyle = TextStyle(
      color: textColor,
      fontSize: 4,
      fontWeight: FontWeight.bold,
    );

    for (final component in simulatorManager.components) {
      final minimapX = (component.position.dx - contentBounds.left) * scale;
      final minimapY = (component.position.dy - contentBounds.top) * scale;
      final minimapWidth = component.size.width * scale;
      final minimapHeight = component.size.height * scale;

      final rect =
          Rect.fromLTWH(minimapX, minimapY, minimapWidth, minimapHeight);
      canvas
        ..drawRect(rect, paint)
        ..drawRect(rect, borderPaint);

      final textSpan = TextSpan(
        text: '${component.runtimeType}',
        style: textStyle,
      );

      final textPainter = TextPainter(
        text: textSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: minimapWidth);

      final textX = minimapX + (minimapWidth - textPainter.width) / 2;
      final textY = minimapY + (minimapHeight - textPainter.height) / 2;

      textPainter.paint(canvas, Offset(textX, textY));
    }
  }

  void _drawWires(Canvas canvas) {
    for (final wire in simulatorManager.wires) {
      final paint = Paint()
        ..color = wire.startPin.value ? activeWireColor : wireColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;

      final path = Path();

      final startX = (wire.startPosition.dx - contentBounds.left) * scale;
      final startY = (wire.startPosition.dy - contentBounds.top) * scale;

      path.moveTo(startX, startY);

      if (wire.segments.isEmpty) {
        final endX = (wire.endPosition.dx - contentBounds.left) * scale;
        final endY = (wire.endPosition.dy - contentBounds.top) * scale;

        path.lineTo(endX, endY);
      } else {
        for (final segment in wire.segments) {
          final segX = (segment.dx - contentBounds.left) * scale;
          final segY = (segment.dy - contentBounds.top) * scale;

          path.lineTo(segX, segY);
        }

        final endX = (wire.endPosition.dx - contentBounds.left) * scale;
        final endY = (wire.endPosition.dy - contentBounds.top) * scale;

        path.lineTo(endX, endY);
      }

      canvas.drawPath(path, paint);
    }
  }

  void _drawViewport(Canvas canvas) {
    final viewportLeft = -panOffset.dx;
    final viewportTop = -panOffset.dy;

    final minimapViewportLeft = (viewportLeft - contentBounds.left) * scale;
    final minimapViewportTop = (viewportTop - contentBounds.top) * scale;
    final minimapViewportWidth = viewportSize.width * scale;
    final minimapViewportHeight = viewportSize.height * scale;

    final viewportRect = Rect.fromLTWH(
      minimapViewportLeft,
      minimapViewportTop,
      minimapViewportWidth,
      minimapViewportHeight,
    );

    final paint = Paint()
      ..color = viewportColor.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;
    canvas.drawRect(viewportRect, paint);

    final borderPaint = Paint()
      ..color = viewportColor.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRect(viewportRect, borderPaint);
  }

  @override
  bool shouldRepaint(_MinimapPainter oldDelegate) =>
      oldDelegate.simulatorManager != simulatorManager ||
      oldDelegate.viewportSize != viewportSize ||
      oldDelegate.panOffset != panOffset ||
      oldDelegate.contentBounds != contentBounds ||
      oldDelegate.scale != scale;
}
