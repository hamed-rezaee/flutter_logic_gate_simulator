import 'dart:math';

import 'package:flutter/material.dart';

enum LogicGateType { and, or, not, nand, nor, xor, xnor }

class LogicGate extends StatelessWidget {
  const LogicGate({
    required this.gateType,
    this.gateColor = Colors.white,
    this.strokeWidth = 3,
    super.key,
  });

  final LogicGateType gateType;
  final Color gateColor;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) => SizedBox.expand(
        child: CustomPaint(
          painter: _LogicGatesPainter(
            gateType: gateType,
            gateColor: gateColor,
            strokeWidth: strokeWidth,
          ),
        ),
      );
}

class _LogicGatesPainter extends CustomPainter {
  _LogicGatesPainter({
    required this.gateType,
    required this.gateColor,
    required this.strokeWidth,
  });

  final LogicGateType gateType;
  final Color gateColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = gateColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final gateWidth = size.width * 0.5;
    final gateHeight = size.height * 0.6;

    switch (gateType) {
      case LogicGateType.and:
        _drawAndGate(
          canvas,
          size,
          paint,
          centerX,
          centerY,
          gateWidth,
          gateHeight,
        );
      case LogicGateType.or:
        _drawOrGate(
          canvas,
          size,
          paint,
          centerX,
          centerY,
          gateWidth,
          gateHeight,
        );
      case LogicGateType.not:
        _drawNotGate(
          canvas,
          size,
          paint,
          centerX,
          centerY,
          gateWidth,
          gateHeight,
        );
      case LogicGateType.nand:
        _drawNandGate(
          canvas,
          size,
          paint,
          centerX,
          centerY,
          gateWidth,
          gateHeight,
        );
      case LogicGateType.nor:
        _drawNorGate(
          canvas,
          size,
          paint,
          centerX,
          centerY,
          gateWidth,
          gateHeight,
        );
      case LogicGateType.xor:
        _drawXorGate(
          canvas,
          size,
          paint,
          centerX,
          centerY,
          gateWidth,
          gateHeight,
        );
      case LogicGateType.xnor:
        _drawXnorGate(
          canvas,
          size,
          paint,
          centerX,
          centerY,
          gateWidth,
          gateHeight,
        );
    }
  }

  void _drawAndGate(
    Canvas canvas,
    Size size,
    Paint paint,
    double centerX,
    double centerY,
    double gateWidth,
    double gateHeight,
  ) {
    final leftX = centerX - gateWidth / 2;
    final rightX = centerX + gateWidth / 2;
    final topY = centerY - gateHeight / 2;
    final bottomY = centerY + gateHeight / 2;

    canvas
      ..drawLine(Offset(leftX, topY), Offset(leftX, bottomY), paint)
      ..drawLine(
        Offset(leftX, topY),
        Offset(rightX - gateHeight / 2, topY),
        paint,
      )
      ..drawLine(
        Offset(leftX, bottomY),
        Offset(rightX - gateHeight / 2, bottomY),
        paint,
      );

    final rect = Rect.fromLTRB(rightX - gateHeight, topY, rightX, bottomY);

    canvas.drawArc(rect, -pi / 2, pi, false, paint);
  }

  void _drawOrGate(
    Canvas canvas,
    Size size,
    Paint paint,
    double centerX,
    double centerY,
    double gateWidth,
    double gateHeight,
  ) {
    final leftX = centerX - gateWidth / 2;
    final rightX = centerX + gateWidth / 2;
    final topY = centerY - gateHeight / 2;
    final bottomY = centerY + gateHeight / 2;

    final path = Path()
      ..moveTo(leftX, topY)
      ..quadraticBezierTo(
        leftX + gateWidth * 0.25,
        centerY,
        leftX,
        bottomY,
      );
    canvas.drawPath(path, paint);

    final rightSide = Path()
      ..moveTo(leftX, topY)
      ..quadraticBezierTo(
        leftX + gateWidth * 0.6,
        topY,
        rightX - gateHeight / 10,
        centerY,
      )
      ..quadraticBezierTo(leftX + gateWidth * 0.6, bottomY, leftX, bottomY);

    canvas.drawPath(rightSide, paint);
  }

  void _drawNotGate(
    Canvas canvas,
    Size size,
    Paint paint,
    double centerX,
    double centerY,
    double gateWidth,
    double gateHeight,
  ) {
    final leftX = centerX - gateWidth / 2;
    final rightX = centerX + gateWidth / 2;
    final topY = centerY - gateHeight / 2;
    final bottomY = centerY + gateHeight / 2;

    final path = Path()
      ..moveTo(leftX, topY)
      ..lineTo(leftX, bottomY)
      ..lineTo(rightX - gateHeight / 4, centerY)
      ..close();

    canvas
      ..drawPath(path, paint)
      ..drawCircle(Offset(rightX, centerY), gateHeight / 8, paint);
  }

  void _drawNandGate(
    Canvas canvas,
    Size size,
    Paint paint,
    double centerX,
    double centerY,
    double gateWidth,
    double gateHeight,
  ) {
    _drawAndGate(
      canvas,
      size,
      paint,
      centerX,
      centerY,
      gateWidth - gateHeight / 4,
      gateHeight,
    );

    final rightX = centerX + gateWidth / 2;

    canvas.drawCircle(Offset(rightX, centerY), gateHeight / 8, paint);
  }

  void _drawNorGate(
    Canvas canvas,
    Size size,
    Paint paint,
    double centerX,
    double centerY,
    double gateWidth,
    double gateHeight,
  ) {
    _drawOrGate(
      canvas,
      size,
      paint,
      centerX,
      centerY,
      gateWidth - gateHeight / 4,
      gateHeight,
    );

    final rightX = centerX + gateWidth / 2;

    canvas.drawCircle(Offset(rightX, centerY), gateHeight / 8, paint);
  }

  void _drawXorGate(
    Canvas canvas,
    Size size,
    Paint paint,
    double centerX,
    double centerY,
    double gateWidth,
    double gateHeight,
  ) {
    _drawOrGate(canvas, size, paint, centerX, centerY, gateWidth, gateHeight);

    final leftX = centerX - gateWidth / 2;
    final topY = centerY - gateHeight / 2;
    final bottomY = centerY + gateHeight / 2;

    final path = Path()
      ..moveTo(leftX - gateWidth * 0.1, topY)
      ..quadraticBezierTo(
        leftX - gateWidth * 0.1 + gateWidth * 0.15,
        centerY,
        leftX - gateWidth * 0.1,
        bottomY,
      );

    canvas.drawPath(path, paint);
  }

  void _drawXnorGate(
    Canvas canvas,
    Size size,
    Paint paint,
    double centerX,
    double centerY,
    double gateWidth,
    double gateHeight,
  ) {
    _drawXorGate(
      canvas,
      size,
      paint,
      centerX,
      centerY,
      gateWidth - gateHeight / 4,
      gateHeight,
    );

    final rightX = centerX + gateWidth / 2;

    canvas.drawCircle(Offset(rightX, centerY), gateHeight / 8, paint);
  }

  @override
  bool shouldRepaint(_LogicGatesPainter oldDelegate) =>
      oldDelegate.gateType != gateType ||
      oldDelegate.gateColor != gateColor ||
      oldDelegate.strokeWidth != strokeWidth;
}
