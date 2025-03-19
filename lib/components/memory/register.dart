import 'package:flutter/material.dart';
import 'package:flutter_logic_gate_simulator/components/components.dart';

class Register extends BaseLogicComponent with PinNamingMixin {
  Register({required super.id, required super.position}) {
    for (var i = 0; i < 6; i++) {
      inputPins.add(Pin(index: i, component: this));
    }

    for (var i = 0; i < 4; i++) {
      outputPins.add(Pin(index: i, component: this, isOutput: true));
    }

    setupDefaultPinNames(
      inputNames: ['D0', 'D1', 'D2', 'D3', 'CLK', 'LD'],
      outputNames: ['Y0', 'Y1', 'Y2', 'Y3'],
    );
  }

  final List<bool> storedValues = [false, false, false, false];
  bool previousClock = false;

  @override
  Size get size => const Size(120, 100);

  @override
  Widget build({
    required VoidCallback onInputToggle,
    required void Function(Pin pin) onPinTap,
    bool isSelected = false,
  }) =>
      ComponentBuilder(
        id: id,
        child: const ComponentLabel(title: 'Register'),
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
    final dataInputs = inputPins.sublist(0, 4).map((pin) => pin.value).toList();
    final clock = inputPins[4].value;
    final load = inputPins[5].value;

    if (clock && !previousClock && load) {
      for (var i = 0; i < storedValues.length; i++) {
        storedValues[i] = dataInputs[i];
      }
    }

    for (var i = 0; i < outputPins.length; i++) {
      outputPins[i].value = storedValues[i];
    }

    previousClock = clock;
  }
}
