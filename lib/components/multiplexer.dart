import 'package:flutter/material.dart';
import 'package:flutter_logic_gate_simulator/components/base_logic_component.dart';
import 'package:flutter_logic_gate_simulator/components/component_builder.dart';
import 'package:flutter_logic_gate_simulator/components/pin.dart';

class Multiplexer extends BaseLogicComponent {
  Multiplexer({required super.id, required super.position}) {
    for (var i = 0; i < 6; i++) {
      inputPins.add(Pin(index: i, isOutput: false, component: this));
    }

    outputPins.add(Pin(index: 0, isOutput: true, component: this));
  }

  @override
  Size get size => const Size(80, 115);

  @override
  Widget build({
    required VoidCallback onInputToggle,
    required void Function(Pin pin) onPinTap,
    bool isSelected = false,
  }) =>
      ComponentBuilder(
        id: id,
        child: const Text(
          'MUX',
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
    final s0 = inputPins[4].value;
    final s1 = inputPins[5].value;

    final selectedInput = (s1 ? 2 : 0) | (s0 ? 1 : 0);

    selectedInput < 4
        ? outputPins[0].value = inputPins[selectedInput].value
        : outputPins[0].value = false;
  }

  @override
  BaseLogicComponent clone() => Multiplexer(id: id, position: position);
}
