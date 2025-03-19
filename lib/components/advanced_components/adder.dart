import 'package:flutter/material.dart';
import 'package:flutter_logic_gate_simulator/components/components.dart';

class Adder extends BaseLogicComponent with PinNamingMixin {
  Adder({required super.id, required super.position}) {
    for (var i = 0; i < 3; i++) {
      inputPins.add(Pin(index: i, component: this));
    }

    for (var i = 0; i < 2; i++) {
      outputPins.add(Pin(index: i, component: this, isOutput: true));
    }

    setupDefaultPinNames(
      inputNames: ['A', 'B', 'Cin'],
      outputNames: ['S', 'Cout'],
    );
  }

  @override
  Size get size => const Size(110, 65);

  @override
  Widget build({
    required VoidCallback onInputToggle,
    required void Function(Pin pin) onPinTap,
    bool isSelected = false,
  }) =>
      ComponentBuilder(
        id: id,
        child: const ComponentLabel(title: 'Adder'),
        inputPins: inputPins,
        outputPins: outputPins,
        isSelected: isSelected,
        position: position,
        size: size,
        onInputToggle: onInputToggle,
        onPinTap: onPinTap,
      );

  @override
  void calculateOutput() {
    final sum = inputPins[0].value ^ inputPins[1].value ^ inputPins[2].value;
    final carryOut = (inputPins[0].value && inputPins[1].value) ||
        (inputPins[0].value && inputPins[2].value) ||
        (inputPins[1].value && inputPins[2].value);

    outputPins[0].value = sum;
    outputPins[1].value = carryOut;
  }
}
