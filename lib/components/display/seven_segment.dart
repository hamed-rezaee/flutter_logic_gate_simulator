import 'package:flutter/material.dart';
import 'package:flutter_logic_gate_simulator/components/components.dart';

class SevenSegment extends BaseLogicComponent
    with PinNamingMixin, ComponentInformationMixin {
  SevenSegment({required super.id, required super.position}) {
    for (var i = 0; i < 7; i++) {
      inputPins.add(Pin(index: i, component: this));
    }

    setupDefaultPinNames(inputNames: const ['A', 'B', 'C', 'D', 'E', 'F', 'G']);
  }

  @override
  Size get size => const Size(100, 125);

  @override
  String get title => '7-Segment Display';

  @override
  String get description =>
      'The 7-segment display component displays a 4-bit input as a 7-segment pattern.';

  @override
  Map<String, String> get properties => {
        'Inputs': inputNames,
        'Outputs': outputNames,
        'Operation':
            'Displays the 7-segment pattern of the input value. Use 7-segment decoders to convert binary to 7-segment pattern.',
      };

  @override
  Widget build({
    required VoidCallback onInputToggle,
    required void Function(Pin) onPinTap,
    bool isSelected = false,
  }) =>
      ComponentBuilder(
        id: id,
        child: _SevenSegmentView(
          a: inputPins[0].value,
          b: inputPins[1].value,
          c: inputPins[2].value,
          d: inputPins[3].value,
          e: inputPins[4].value,
          f: inputPins[5].value,
          g: inputPins[6].value,
        ),
        inputPins: inputPins,
        outputPins: outputPins,
        information: information,
        isSelected: isSelected,
        position: position,
        size: size,
        onInputToggle: onInputToggle,
        onPinTap: onPinTap,
      );

  @override
  void calculateOutput() {}
}

class _SevenSegmentView extends StatelessWidget {
  const _SevenSegmentView({
    required this.a,
    required this.b,
    required this.c,
    required this.d,
    required this.e,
    required this.f,
    required this.g,
  });

  final bool a;
  final bool b;
  final bool c;
  final bool d;
  final bool e;
  final bool f;
  final bool g;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 50,
        height: 75,
        child: CustomPaint(
          painter:
              _SevenSegmentPainter(a: a, b: b, c: c, d: d, e: e, f: f, g: g),
        ),
      );
}

class _SevenSegmentPainter extends CustomPainter {
  _SevenSegmentPainter({
    required this.a,
    required this.b,
    required this.c,
    required this.d,
    required this.e,
    required this.f,
    required this.g,
  });

  final bool a;
  final bool b;
  final bool c;
  final bool d;
  final bool e;
  final bool f;
  final bool g;

  @override
  void paint(Canvas canvas, Size size) {
    final segmentWidth = size.width * 0.15;
    final height = size.height;
    final width = size.width;

    final activePaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 8);

    final inactivePaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;

    _drawHorizontalSegment(
      canvas,
      Offset(segmentWidth, segmentWidth / 2 - 4),
      width - 2 * segmentWidth,
      segmentWidth,
      a ? activePaint : inactivePaint,
    );

    _drawVerticalSegment(
      canvas,
      Offset(width - segmentWidth * 1.5, segmentWidth),
      segmentWidth,
      height / 2 - segmentWidth,
      b ? activePaint : inactivePaint,
    );

    _drawVerticalSegment(
      canvas,
      Offset(width - segmentWidth * 1.5, height / 2 + segmentWidth),
      segmentWidth,
      height / 2 - segmentWidth * 1.5,
      c ? activePaint : inactivePaint,
    );

    _drawHorizontalSegment(
      canvas,
      Offset(segmentWidth, height - segmentWidth * 1.5 + 8),
      width - 2 * segmentWidth,
      segmentWidth,
      d ? activePaint : inactivePaint,
    );

    _drawVerticalSegment(
      canvas,
      Offset(segmentWidth / 2, height / 2 + segmentWidth),
      segmentWidth,
      height / 2 - segmentWidth * 1.5,
      e ? activePaint : inactivePaint,
    );

    _drawVerticalSegment(
      canvas,
      Offset(segmentWidth / 2, segmentWidth),
      segmentWidth,
      height / 2 - segmentWidth,
      f ? activePaint : inactivePaint,
    );

    _drawHorizontalSegment(
      canvas,
      Offset(segmentWidth, height / 2 - segmentWidth / 2 + 4),
      width - 2 * segmentWidth,
      segmentWidth,
      g ? activePaint : inactivePaint,
    );
  }

  void _drawHorizontalSegment(
    Canvas canvas,
    Offset offset,
    double width,
    double height,
    Paint paint,
  ) {
    final path = Path()
      ..moveTo(offset.dx, offset.dy + height / 2)
      ..lineTo(offset.dx + height / 2, offset.dy)
      ..lineTo(offset.dx + width - height / 2, offset.dy)
      ..lineTo(offset.dx + width, offset.dy + height / 2)
      ..lineTo(offset.dx + width - height / 2, offset.dy + height)
      ..lineTo(offset.dx + height / 2, offset.dy + height)
      ..close();

    canvas.drawPath(path, paint);
  }

  void _drawVerticalSegment(
    Canvas canvas,
    Offset offset,
    double width,
    double height,
    Paint paint,
  ) {
    final path = Path()
      ..moveTo(offset.dx + width / 2, offset.dy)
      ..lineTo(offset.dx + width, offset.dy + width / 2)
      ..lineTo(offset.dx + width, offset.dy + height - width / 2)
      ..lineTo(offset.dx + width / 2, offset.dy + height)
      ..lineTo(offset.dx, offset.dy + height - width / 2)
      ..lineTo(offset.dx, offset.dy + width / 2)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_SevenSegmentPainter oldDelegate) =>
      oldDelegate.a != a ||
      oldDelegate.b != b ||
      oldDelegate.c != c ||
      oldDelegate.d != d ||
      oldDelegate.e != e ||
      oldDelegate.f != f ||
      oldDelegate.g != g;
}
