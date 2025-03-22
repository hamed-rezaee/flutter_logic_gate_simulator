import 'package:flutter/material.dart';

class CanvasCoordinateSystem {
  CanvasCoordinateSystem({this.panOffset = Offset.zero});

  Offset panOffset;

  Offset screenToCanvas(Offset screenPosition) => screenPosition - panOffset;

  Offset canvasToScreen(Offset canvasPosition) => canvasPosition + panOffset;

  void addPanDelta(Offset delta) => panOffset += delta;
}
