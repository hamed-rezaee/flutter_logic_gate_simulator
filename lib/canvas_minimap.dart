import 'package:flutter/material.dart';
import 'package:flutter_logic_gate_simulator/base_canvas_painter.dart';
import 'package:flutter_logic_gate_simulator/canvas_bounds_calculator.dart';
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
    final (Rect contentBounds, double scale) =
        CanvasBoundsCalculator.calculateContentBounds(
      simulatorManager: simulatorManager,
      viewportSize: size,
    );

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
            painter: MinimapPainter(
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
