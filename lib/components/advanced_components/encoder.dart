import 'package:flutter/material.dart';
import 'package:flutter_logic_gate_simulator/components/components.dart';

class Encoder extends BaseLogicComponent with PinNamingMixin {
  Encoder({required super.id, required super.position}) {
    for (var i = 0; i < 4; i++) {
      inputPins.add(Pin(index: i, component: this));
    }

    for (var i = 0; i < 2; i++) {
      outputPins.add(Pin(index: i, component: this, isOutput: true));
    }

    setupDefaultPinNames(
      inputNames: const ['I0', 'I1', 'I2', 'I3'],
      outputNames: ['Y0', 'Y1'],
    );
  }

  @override
  Size get size => const Size(105, 75);

  @override
  Widget build({
    required VoidCallback onInputToggle,
    required void Function(Pin) onPinTap,
    bool isSelected = false,
  }) =>
      ComponentBuilder(
        id: id,
        child: const ComponentLabel(title: 'Encoder'),
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
    var value = 0;

    for (var i = inputPins.length - 1; i >= 0; i--) {
      if (inputPins[i].value) {
        value = i;
        break;
      }
    }

    outputPins[1].value = (value & 0x02) != 0;
    outputPins[0].value = (value & 0x01) != 0;
  }
}
