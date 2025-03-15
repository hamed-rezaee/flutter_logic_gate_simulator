import 'package:flutter/material.dart';
import 'package:flutter_logic_gate_simulator/components/component_builder.dart';
import 'package:flutter_logic_gate_simulator/components/logic_components/base_logic_component.dart';
import 'package:flutter_logic_gate_simulator/components/pin.dart';

class Input extends BaseLogicComponent {
  Input({required super.id, required super.position}) {
    outputPins.add(Pin(component: this, isOutput: true, index: 0));
  }

  bool isOn = false;

  @override
  Widget build({
    required VoidCallback onInputToggle,
    required void Function(Pin) onPinTap,
  }) => ComponentBuilder(
    id: id,
    child: ScaleTransition(
      scale: const AlwaysStoppedAnimation(0.7),
      child: Switch(
        value: isOn,
        activeColor: Colors.green,
        onChanged: (value) {
          isOn = value;
          onInputToggle();
        },
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
  void calculateOutput() => outputPins[0].value = isOn;

  @override
  BaseLogicComponent clone() => Input(position: position, id: id);
}
