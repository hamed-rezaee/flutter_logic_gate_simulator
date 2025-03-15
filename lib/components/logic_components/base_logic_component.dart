import 'package:flutter/material.dart';
import 'package:flutter_logic_gate_simulator/components/pin.dart';

abstract class BaseLogicComponent {
  BaseLogicComponent({required this.id, required this.position});

  final int id;
  final List<Pin> inputPins = [];
  final List<Pin> outputPins = [];

  Offset position;
  bool visited = false;

  Size get size => const Size(80, 40);

  Widget build({
    required VoidCallback onInputToggle,
    required void Function(Pin pin) onPinTap,
  }) => throw UnimplementedError();

  void calculateOutput() => throw UnimplementedError();

  BaseLogicComponent clone() => throw UnimplementedError();

  void resetVisited() => visited = false;
}
