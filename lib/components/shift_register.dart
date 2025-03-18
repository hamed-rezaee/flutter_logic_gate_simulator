import 'package:flutter/material.dart';
import 'package:flutter_logic_gate_simulator/components/base_logic_component.dart';
import 'package:flutter_logic_gate_simulator/components/component_builder.dart';
import 'package:flutter_logic_gate_simulator/components/pin.dart';

class ShiftRegister extends BaseLogicComponent {
  ShiftRegister({required super.id, required super.position}) {
    for (var i = 0; i < 3; i++) {
      inputPins.add(Pin(index: i, isOutput: false, component: this));
    }

    for (var i = 0; i < 4; i++) {
      outputPins.add(Pin(index: i, isOutput: true, component: this));
    }
  }

  final List<bool> _register = [false, false, false, false];

  bool _prevClockState = false;

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
          'SHIFT REG',
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

  @override
  BaseLogicComponent clone() => ShiftRegister(id: id, position: position);
}
