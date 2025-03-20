import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_logic_gate_simulator/components/components.dart';

class Oscilloscope extends BaseLogicComponent
    with PinNamingMixin, TooltipMixin {
  Oscilloscope({required super.id, required super.position}) {
    for (var i = 0; i < 4; i++) {
      inputPins.add(Pin(index: i, component: this));
    }

    setupDefaultPinNames(inputNames: ['A', 'B', 'C', 'D']);
  }

  static const sampleLength = 200;

  static const List<Color> _signalColors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.orange,
  ];

  final List<Queue<bool>> _signalHistory = List.generate(
    4,
    (_) => Queue<bool>()..addAll(List.filled(sampleLength, false)),
  );

  @override
  Size get size => const Size(200, 70);

  @override
  String get tooltipTitle => 'Oscilloscope';

  @override
  String get tooltipDescription =>
      'The oscilloscope component displays the input signals over time.';

  @override
  Map<String, String> get tooltipProperties => {
        'Inputs': inputNames,
        'Outputs': outputNames,
        'Operation': 'Displays the input signals over time.',
      };

  @override
  Widget build({
    required VoidCallback onInputToggle,
    required void Function(Pin pin) onPinTap,
    bool isSelected = false,
  }) =>
      ComponentBuilder(
        id: id,
        child: OscilloscopeDisplay(
          signalHistory: _signalHistory,
          signalColors: _signalColors,
        ),
        inputPins: inputPins,
        outputPins: outputPins,
        tooltip: tooltip,
        isSelected: isSelected,
        position: position,
        size: size,
        onInputToggle: onInputToggle,
        onPinTap: onPinTap,
      );

  @override
  void calculateOutput() => _sampleInputs();

  void _sampleInputs() {
    for (var i = 0; i < inputPins.length; i++) {
      if (_signalHistory[i].length >= sampleLength) {
        _signalHistory[i].removeFirst();
      }

      _signalHistory[i].add(inputPins[i].value);
    }
  }
}

class OscilloscopeDisplay extends StatelessWidget {
  const OscilloscopeDisplay({
    required this.signalHistory,
    required this.signalColors,
    super.key,
  });

  final List<Queue<bool>> signalHistory;
  final List<Color> signalColors;

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
  });

  final List<Queue<bool>> signalHistory;
  final List<Color> signalColors;

  @override
  void paint(Canvas canvas, Size size) {
    _drawGrid(canvas, size);

    for (var i = 0; i < signalHistory.length; i++) {
      _drawSignal(
        canvas,
        size,
        signalHistory[i].toList(),
        signalColors[i],
        i,
      );
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
