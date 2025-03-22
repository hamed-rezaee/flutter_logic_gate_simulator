import 'package:flutter/material.dart';
import 'package:flutter_logic_gate_simulator/simulator_manager.dart';
import 'package:flutter_logic_gate_simulator/wire_painter.dart';

abstract class BaseCanvasPainter extends CustomPainter {
  const BaseCanvasPainter({
    required this.simulatorManager,
    required this.panOffset,
    this.wireColor = Colors.grey,
    this.activeWireColor = Colors.green,
    this.selectedWireColor = Colors.blueGrey,
  });

  final SimulatorManager simulatorManager;
  final Offset panOffset;
  final Color wireColor;
  final Color activeWireColor;
  final Color selectedWireColor;

  void _drawWires(Canvas canvas) {
    for (final wire in simulatorManager.wires) {
      final isSelected = wire == simulatorManager.selectedWire;

      WirePainter.drawWire(
        canvas: canvas,
        wire: wire,
        panOffset: panOffset,
        isSelected: isSelected,
        activeWireColor: activeWireColor,
        wireColor: wireColor,
        selectedWireColor: selectedWireColor,
      );
    }
  }
}

class WiresCanvasPainter extends BaseCanvasPainter {
  const WiresCanvasPainter({
    required super.simulatorManager,
    required super.panOffset,
    this.activeWire,
    super.wireColor,
    super.activeWireColor,
    super.selectedWireColor,
  });

  final Map<String, dynamic>? activeWire;

  @override
  void paint(Canvas canvas, Size size) {
    _drawWires(canvas);

    if (activeWire != null) {
      WirePainter.drawTempWire(
        canvas: canvas,
        start: activeWire!['start'] as Offset,
        end: activeWire!['end'] as Offset,
        segments: activeWire!['segments'] as List<Offset>,
        isActive: activeWire!['isActive'] as bool,
        isDashed: activeWire!['isDashed'] as bool,
        panOffset: panOffset,
        wireColor: wireColor,
      );
    }
  }

  @override
  bool shouldRepaint(WiresCanvasPainter oldDelegate) =>
      oldDelegate.simulatorManager.selectedWire !=
          simulatorManager.selectedWire ||
      oldDelegate.panOffset != panOffset ||
      oldDelegate.simulatorManager.wires.length !=
          simulatorManager.wires.length ||
      oldDelegate.activeWire != activeWire;
}

class MinimapPainter extends BaseCanvasPainter {
  const MinimapPainter({
    required super.simulatorManager,
    required this.viewportSize,
    required super.panOffset,
    required this.contentBounds,
    required this.scale,
    required this.componentColor,
    required this.viewportColor,
    required this.textColor,
    super.wireColor,
    super.activeWireColor,
  });

  final Size viewportSize;
  final Rect contentBounds;
  final double scale;
  final Color componentColor;
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

      final borderPaint = Paint()
        ..color = simulatorManager.selectedComponent == component
            ? Colors.orange
            : componentColor.withValues(alpha: 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

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

  @override
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
  bool shouldRepaint(MinimapPainter oldDelegate) =>
      oldDelegate.simulatorManager != simulatorManager ||
      oldDelegate.viewportSize != viewportSize ||
      oldDelegate.panOffset != panOffset ||
      oldDelegate.contentBounds != contentBounds ||
      oldDelegate.scale != scale;
}
