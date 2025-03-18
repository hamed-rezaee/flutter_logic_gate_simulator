import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_logic_gate_simulator/components/components.dart';

class Oscilloscope extends BaseLogicComponent {
  Oscilloscope({required super.id, required super.position}) {
    for (var i = 0; i < 6; i++) {
      inputPins.add(Pin(index: i, isOutput: false, component: this));
    }
  }

  final List<Queue<bool>> _signalHistory = List.generate(
    6,
    (_) => Queue<bool>()..addAll(List.filled(100, false)),
  );

  final List<Color> _signalColors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.yellow,
    Colors.purple,
    Colors.orange,
  ];

  final List<bool> _activeChannels = List.filled(6, false);

  @override
  Size get size => const Size(300, 110);

  @override
  Widget build({
    required VoidCallback onInputToggle,
    required void Function(Pin pin) onPinTap,
    bool isSelected = false,
  }) {
    return ComponentBuilder(
      id: id,
      child: OscilloscopeDisplay(
        signalHistory: _signalHistory,
        signalColors: _signalColors,
        activeChannels: _activeChannels,
      ),
      inputPins: inputPins,
      outputPins: outputPins,
      isSelected: isSelected,
      position: position,
      size: size,
      onInputToggle: onInputToggle,
      onPinTap: onPinTap,
    );
  }

  @override
  void calculateOutput() => _sampleInputs();

  @override
  BaseLogicComponent clone() => Oscilloscope(id: id, position: position);

  void _sampleInputs() {
    for (var i = 0; i < inputPins.length; i++) {
      if (_signalHistory[i].length >= 300) _signalHistory[i].removeFirst();

      _signalHistory[i].add(inputPins[i].value);

      if (inputPins[i].value) _activeChannels[i] = true;
    }
  }
}

class OscilloscopeDisplay extends StatelessWidget {
  const OscilloscopeDisplay({
    required this.signalHistory,
    required this.signalColors,
    required this.activeChannels,
    super.key,
  });

  final List<Queue<bool>> signalHistory;
  final List<Color> signalColors;
  final List<bool> activeChannels;

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: Colors.black,
          border: Border.all(color: Colors.grey[700]!, width: 2),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: CustomPaint(
                  size: Size.infinite,
                  painter: OscilloscopePainter(
                    signalHistory: signalHistory,
                    signalColors: signalColors,
                    activeChannels: activeChannels,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
}

class OscilloscopePainter extends CustomPainter {
  OscilloscopePainter({
    required this.signalHistory,
    required this.signalColors,
    required this.activeChannels,
  });

  final List<Queue<bool>> signalHistory;
  final List<Color> signalColors;
  final List<bool> activeChannels;

  @override
  void paint(Canvas canvas, Size size) {
    _drawGrid(canvas, size);

    for (var i = 0; i < signalHistory.length; i++) {
      if (activeChannels[i]) {
        _drawSignal(
          canvas,
          size,
          signalHistory[i].toList(),
          signalColors[i],
          i,
        );
      }
    }
  }

  void _drawSignal(
    Canvas canvas,
    Size size,
    List<bool> signal,
    Color color,
    int channelIndex,
  ) {
    final signalPaint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    if (signal.isEmpty) return;

    final path = Path();
    final points = <Offset>[];

    final rowHeight = size.height / signalHistory.length;

    final baseY = (channelIndex + 0.5) * rowHeight;

    final amplitude = rowHeight * 0.4;

    for (var i = 0; i < signal.length; i++) {
      final x = i * (size.width / signal.length);

      final y = signal[i] ? baseY - amplitude : baseY + amplitude;
      points.add(Offset(x, y));
    }

    path.moveTo(points.first.dx, points.first.dy);

    for (var i = 1; i < points.length; i++) {
      if (signal[i] != signal[i - 1]) {
        final midX = (points[i].dx + points[i - 1].dx) / 2;

        path
          ..lineTo(midX, points[i - 1].dy)
          ..lineTo(midX, points[i].dy);
      }
      path.lineTo(points[i].dx, points[i].dy);
    }

    canvas.drawPath(path, signalPaint);
  }

  void _drawGrid(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.2)
      ..strokeWidth = 0.5;

    for (var i = 0; i <= signalHistory.length; i++) {
      final y = i * (size.height / signalHistory.length);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    for (var i = 0; i <= 10; i++) {
      final x = i * (size.width / 10);
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
  }

  @override
  bool shouldRepaint(OscilloscopePainter oldDelegate) => true;
}
