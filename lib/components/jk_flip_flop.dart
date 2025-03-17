import 'package:flutter/material.dart';
import 'package:flutter_logic_gate_simulator/components/base_logic_component.dart';
import 'package:flutter_logic_gate_simulator/components/component_builder.dart';
import 'package:flutter_logic_gate_simulator/components/pin.dart';

class JKFlipFlop extends BaseLogicComponent {
  JKFlipFlop({required super.id, required super.position}) {
    for (var i = 0; i < 4; i++) {
      inputPins.add(Pin(component: this, isOutput: false, index: i));
    }

    for (var i = 0; i < 2; i++) {
      outputPins.add(Pin(component: this, isOutput: true, index: i));
    }
  }

  bool state = false;
  bool _previousClock = false;

  @override
  Size get size => const Size(80, 80);

  @override
  Widget build({
    required VoidCallback onInputToggle,
    required void Function(Pin) onPinTap,
    bool isSelected = false,
  }) => ComponentBuilder(
    id: id,
    child: const Text(
      'JK FF',
      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    ),
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
    final jInput = inputPins[0].value;
    final kInput = inputPins[1].value;
    final clockInput = inputPins[2].value;
    final resetInput = inputPins[3].value;

    if (!resetInput) {
      state = false;
    } else if (clockInput && !_previousClock) {
      if (jInput && kInput) {
        state = !state;
      } else if (jInput) {
        state = true;
      } else if (kInput) {
        state = false;
      }
    }

    outputPins[0].value = state;
    outputPins[1].value = !state;

    _previousClock = clockInput;
  }

  @override
  BaseLogicComponent clone() => JKFlipFlop(position: position, id: id);
}
