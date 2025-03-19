import 'package:flutter/material.dart';
import 'package:flutter_logic_gate_simulator/components/components.dart';

class ShiftRegister extends BaseLogicComponent with PinNamingMixin {
  ShiftRegister({required super.id, required super.position}) {
    for (var i = 0; i < 3; i++) {
      inputPins.add(Pin(index: i, component: this));
    }

    for (var i = 0; i < 4; i++) {
      outputPins.add(Pin(index: i, component: this, isOutput: true));
    }

    setupDefaultPinNames(
      inputNames: const ['IN', 'CLK', 'RST'],
      outputNames: ['Y0', 'Y1', 'Y2', 'Y3'],
    );
  }

  final List<bool> _register = [false, false, false, false];

  bool _prevClockState = false;

  @override
  Size get size => const Size(120, 60);

  @override
  Widget build({
    required VoidCallback onInputToggle,
    required void Function(Pin pin) onPinTap,
    bool isSelected = false,
  }) =>
      ComponentBuilder(
        id: id,
        child: const ComponentLabel(title: 'Shift\nRegister'),
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
    final dataIn = inputPins[0].value;
    final clock = inputPins[1].value;
    final reset = inputPins[2].value;

    if (reset) {
      for (var i = 0; i < _register.length; i++) {
        _register[i] = false;
      }
    } else if (clock && !_prevClockState) {
      for (var i = _register.length - 1; i > 0; i--) {
        _register[i] = _register[i - 1];
      }

      _register[0] = dataIn;
    }

    for (var i = 0; i < outputPins.length; i++) {
      outputPins[i].value = _register[i];
    }

    _prevClockState = clock;
  }
}
