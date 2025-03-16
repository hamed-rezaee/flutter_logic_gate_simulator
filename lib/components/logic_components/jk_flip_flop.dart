import 'package:flutter/material.dart';
import 'package:flutter_logic_gate_simulator/components/component_builder.dart';
import 'package:flutter_logic_gate_simulator/components/logic_components/base_logic_component.dart';
import 'package:flutter_logic_gate_simulator/components/pin.dart';

class JkFlipFlop extends BaseLogicComponent {
  JkFlipFlop({required super.id, required super.position}) {
    inputPins
      ..add(Pin(component: this, isOutput: false, index: 0))
      ..add(Pin(component: this, isOutput: false, index: 1))
      ..add(Pin(component: this, isOutput: false, index: 2));

    outputPins
      ..add(Pin(component: this, isOutput: true, index: 0))
      ..add(Pin(component: this, isOutput: true, index: 1));

    outputPins[0].value = false;
    outputPins[1].value = true;
  }

  bool _previousClock = false;

  @override
  Size get size => const Size(80, 60);

  @override
  Widget build({
    required VoidCallback onInputToggle,
    required void Function(Pin) onPinTap,
  }) => ComponentBuilder(
    id: id,
    child: const Text(
      'JK FF',
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    ),
    inputPins: inputPins,
    outputPins: outputPins,
    position: position,
    size: size,
    onInputToggle: onInputToggle,
    onPinTap: onPinTap,
  );

  @override
  void calculateOutput() {
    final j = inputPins[0].value;
    final k = inputPins[1].value;
    final clock = inputPins[2].value;

    if (clock && !_previousClock) {
      if (j && k) {
        outputPins[0].value = !outputPins[0].value;
        outputPins[1].value = !outputPins[1].value;
      } else if (j) {
        outputPins[0].value = true;
        outputPins[1].value = false;
      } else if (k) {
        outputPins[0].value = false;
        outputPins[1].value = true;
      }
    }

    _previousClock = clock;
  }

  @override
  BaseLogicComponent clone() => JkFlipFlop(position: position, id: id);
}
