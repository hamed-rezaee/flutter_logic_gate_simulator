import 'package:flutter/material.dart';
import 'package:flutter_logic_gate_simulator/components/components.dart';

class Comparator extends BaseLogicComponent {
  Comparator({required super.id, required super.position}) {
    for (var i = 0; i < 4; i++) {
      inputPins.add(Pin(index: i, isOutput: false, component: this));
    }

    for (var i = 0; i < 3; i++) {
      outputPins.add(Pin(index: i, isOutput: true, component: this));
    }
  }

  @override
  Size get size => const Size(80, 80);

  @override
  Widget build({
    required VoidCallback onInputToggle,
    required void Function(Pin pin) onPinTap,
    bool isSelected = false,
  }) =>
      ComponentBuilder(
        id: id,
        child: const Text(
          'COMP',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        position: position,
        size: size,
        isSelected: isSelected,
        inputPins: inputPins,
        outputPins: outputPins,
        onInputToggle: onInputToggle,
        onPinTap: onPinTap,
      );

  @override
  void calculateOutput() {
    final valueA = (inputPins[0].value ? 1 : 0) | (inputPins[1].value ? 2 : 0);
    final valueB = (inputPins[2].value ? 1 : 0) | (inputPins[3].value ? 2 : 0);

    outputPins[0].value = valueA < valueB;
    outputPins[1].value = valueA == valueB;
    outputPins[2].value = valueA > valueB;
  }

  @override
  BaseLogicComponent clone() => Comparator(id: id, position: position);
}
