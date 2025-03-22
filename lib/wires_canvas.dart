import 'package:flutter/material.dart';
import 'package:flutter_logic_gate_simulator/base_canvas_painter.dart';
import 'package:flutter_logic_gate_simulator/components/components.dart';
import 'package:flutter_logic_gate_simulator/simulator_manager.dart';

class WiresCanvas extends StatelessWidget {
  const WiresCanvas({
    required this.simulatorManager,
    required this.panOffset,
    required this.onWireTap,
    super.key,
  });

  final SimulatorManager simulatorManager;
  final Offset panOffset;
  final void Function(Wire?, Offset) onWireTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTapDown: (details) => _handleTap(context, details.localPosition),
        child: CustomPaint(
          painter: WiresCanvasPainter(
            simulatorManager: simulatorManager,
            panOffset: panOffset,
            activeWire: simulatorManager.isDrawingWire
                ? _createTempWire(simulatorManager)
                : null,
          ),
          size: MediaQuery.of(context).size,
        ),
      );

  Map<String, dynamic>? _createTempWire(SimulatorManager simulatorManager) {
    if (simulatorManager.wireStartPin == null ||
        simulatorManager.wireEndPosition == null) {
      return null;
    }

    final start = simulatorManager.wireStartPin!.position;
    final end = simulatorManager.wireEndPosition!;
    final midX = (start.dx + end.dx) / 2;

    return {
      'start': start,
      'end': end,
      'segments': [
        Offset(midX, start.dy),
        Offset(midX, end.dy),
      ],
      'isActive': simulatorManager.wireStartPin!.value,
      'isDashed': true,
    };
  }

  void _handleTap(BuildContext context, Offset position) {
    final canvasPosition = position - panOffset;

    const threshold = 10.0;
    Wire? tappedWire;

    for (final wire in simulatorManager.wires) {
      final isPointNearWirePath = wire.isPointNearWirePath(
        point: canvasPosition,
        threshold: threshold,
      );

      if (isPointNearWirePath) {
        tappedWire = wire;
        break;
      }
    }

    onWireTap(tappedWire, position);
  }
}
