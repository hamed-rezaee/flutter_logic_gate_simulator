import 'package:flutter/material.dart';
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
  final void Function(WireModel?, Offset) onWireTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTapDown: (details) => _handleTap(context, details.localPosition),
        child: CustomPaint(
          painter: _WiresCanvasPainter(
            wires: simulatorManager.wires,
            selectedWire: simulatorManager.selectedWire,
            panOffset: panOffset,
            activeWire: simulatorManager.isDrawingWire
                ? _createTempWire(simulatorManager)
                : null,
          ),
          size: Size(
            MediaQuery.of(context).size.width,
            MediaQuery.of(context).size.height,
          ),
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
    WireModel? tappedWire;

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

class _WiresCanvasPainter extends CustomPainter {
  const _WiresCanvasPainter({
    required this.wires,
    required this.panOffset,
    this.selectedWire,
    this.activeWire,
  });

  final List<WireModel> wires;
  final WireModel? selectedWire;
  final Offset panOffset;
  final Map<String, dynamic>? activeWire;

  @override
  void paint(Canvas canvas, Size size) {
    for (final wire in wires) {
      final isSelected = wire == selectedWire;
      _drawWire(canvas, wire, isSelected);
    }

    if (activeWire != null) {
      _drawActiveWire(canvas);
    }
  }

  void _drawWire(Canvas canvas, WireModel wire, bool isSelected) {
    final path = _createWirePath(
      wire.startPosition + panOffset,
      wire.endPosition + panOffset,
      wire.segments.map((seg) => seg + panOffset).toList(),
    );

    final paint = Paint()
      ..color = wire.startPin.value ? Colors.green : Colors.grey[200]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = isSelected ? 4 : 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, paint);

    if (isSelected) {
      final highlightPaint = Paint()
        ..color = Colors.blue.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      canvas.drawPath(path, highlightPaint);
    }
  }

  void _drawActiveWire(Canvas canvas) {
    final start = (activeWire!['start'] as Offset) + panOffset;
    final end = (activeWire!['end'] as Offset) + panOffset;
    final segments = (activeWire!['segments'] as List<Offset>)
        .map((seg) => seg + panOffset)
        .toList();

    final path = _createWirePath(start, end, segments);

    final paint = Paint()
      ..color =
          (activeWire!['isActive'] as bool) ? Colors.green : Colors.grey[200]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    if (activeWire!['isDashed'] as bool) {
      _drawDashedPath(canvas, path, paint);
    } else {
      canvas.drawPath(path, paint);
    }
  }

  Path _createWirePath(Offset start, Offset end, List<Offset> segments) {
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

    return path;
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
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

  @override
  bool shouldRepaint(_WiresCanvasPainter oldDelegate) =>
      oldDelegate.selectedWire != selectedWire ||
      oldDelegate.panOffset != panOffset ||
      oldDelegate.wires.length != wires.length ||
      oldDelegate.activeWire != activeWire;
}
