import 'package:flutter/material.dart';
import 'package:flutter_logic_gate_simulator/components/pin.dart';

abstract class BaseLogicComponent {
  BaseLogicComponent({required this.id, required this.position});

  final int id;
  final List<Pin> inputPins = [];
  final List<Pin> outputPins = [];

  Offset position;
  bool visited = false;

  Size get size => const Size(70, 40);

  Widget build({
    required VoidCallback onInputToggle,
    required void Function(Pin pin) onPinTap,
    bool isSelected = false,
  }) =>
      throw UnimplementedError();

  void calculateOutput() => throw UnimplementedError();

  void resetVisited() => visited = false;

  void dispose() {}
}

mixin PinNamingMixin on BaseLogicComponent {
  void setupDefaultPinNames({
    List<String> inputNames = const [],
    List<String> outputNames = const [],
  }) {
    assert(
      inputNames.length == inputPins.length,
      'Input names count must match input pins count',
    );

    assert(
      outputNames.length == outputPins.length,
      'Output names count must match output pins count',
    );

    for (var i = 0; i < inputPins.length; i++) {
      final pin = inputPins[i];
      final name = inputNames[i];

      inputPins[i] = Pin(
        index: pin.index,
        isOutput: pin.isOutput,
        component: pin.component,
        name: name,
      );
    }

    for (var i = 0; i < outputPins.length; i++) {
      final pin = outputPins[i];
      final name = outputNames[i];

      outputPins[i] = Pin(
        index: pin.index,
        isOutput: pin.isOutput,
        component: pin.component,
        name: name,
      );
    }
  }
}
