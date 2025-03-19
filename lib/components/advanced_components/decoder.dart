import 'package:flutter/material.dart';
import 'package:flutter_logic_gate_simulator/components/components.dart';

class Decoder extends BaseLogicComponent with PinNamingMixin {
  Decoder({required super.id, required super.position}) {
    for (var i = 0; i < 3; i++) {
      inputPins.add(Pin(index: i, component: this));
    }

    for (var i = 0; i < 4; i++) {
      outputPins.add(Pin(index: i, component: this, isOutput: true));
    }

    setupDefaultPinNames(
      inputNames: const ['A0', 'A1', 'EN'],
      outputNames: ['Y0', 'Y1', 'Y2', 'Y3'],
    );
  }

  @override
  Size get size => const Size(105, 70);

  @override
  Widget build({
    required VoidCallback onInputToggle,
    required void Function(Pin) onPinTap,
    bool isSelected = false,
  }) =>
      ComponentBuilder(
        id: id,
        child: const ComponentLabel(title: 'Decoder'),
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
    if (!inputPins[2].value) {
      for (final outputPin in outputPins) {
        outputPin.value = false;
      }

      return;
    }

    final a0 = inputPins[0].value ? 1 : 0;
    final a1 = inputPins[1].value ? 1 : 0;
    final index = (a1 << 1) | a0;

    for (var i = 0; i < outputPins.length; i++) {
      outputPins[i].value = i == index;
    }
  }
}
