import 'package:flutter/material.dart';
import 'package:flutter_logic_gate_simulator/components/component_builder.dart';
import 'package:flutter_logic_gate_simulator/components/logic_components/base_logic_component.dart';
import 'package:flutter_logic_gate_simulator/components/pin.dart';

class OrGate extends BaseLogicComponent {
  OrGate({required super.id, required super.position}) {
    inputPins
      ..add(Pin(component: this, isOutput: false, index: 0))
      ..add(Pin(component: this, isOutput: false, index: 1));

    outputPins.add(Pin(component: this, isOutput: true, index: 0));
  }

  @override
  Widget build({
    required VoidCallback onInputToggle,
    required void Function(Pin) onPinTap,
  }) => ComponentBuilder(
    id: id,
    child: const Text(
      'OR',
      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    ),
    inputPins: inputPins,
    outputPins: outputPins,
    position: position,
    size: size,
    onInputToggle: onInputToggle,
    onPinTap: onPinTap,
  );

  @override
  void calculateOutput() =>
      outputPins[0].value = inputPins[0].value || inputPins[1].value;

  @override
  BaseLogicComponent clone() => OrGate(position: position, id: id);
}
