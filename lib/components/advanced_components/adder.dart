import 'package:flutter/material.dart';
import 'package:flutter_logic_gate_simulator/components/components.dart';

class Adder extends BaseLogicComponent with PinNamingMixin {
  Adder({required super.id, required super.position}) {
    for (var i = 0; i < 5; i++) {
      inputPins.add(Pin(index: i, component: this));
    }

    for (var i = 0; i < 3; i++) {
      outputPins.add(Pin(index: i, component: this, isOutput: true));
    }

    setupDefaultPinNames(
      inputNames: ['A0', 'A1', 'B0', 'B1', 'Cin'],
      outputNames: ['S0', 'S1', 'Cout'],
    );
  }

  @override
  Size get size => const Size(110, 95);

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
    final aInputs = inputPins.sublist(0, 2).map((pin) => pin.value).toList();
    final bInputs = inputPins.sublist(2, 4).map((pin) => pin.value).toList();
    final carryIn = inputPins[4].value;
    final sumOutputs = List<bool>.filled(2, false);

    var carry = carryIn;

    for (var i = 0; i < 2; i++) {
      final a = aInputs[i];
      final b = bInputs[i];

      sumOutputs[i] = a ^ b ^ carry;

      carry = (a && b) || (a && carry) || (b && carry);
    }

    for (var i = 0; i < 2; i++) {
      outputPins[i].value = sumOutputs[i];
    }

    outputPins[2].value = carry;
  }
}
