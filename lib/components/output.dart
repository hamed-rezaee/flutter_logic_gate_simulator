import 'package:flutter/material.dart';
import 'package:flutter_logic_gate_simulator/components/components.dart';

class Output extends BaseLogicComponent {
  Output({required super.id, required super.position}) {
    inputPins.add(Pin(component: this, isOutput: false, index: 0));
  }

  @override
  Widget build({
    required VoidCallback onInputToggle,
    required void Function(Pin) onPinTap,
    bool isSelected = false,
  }) =>
      ComponentBuilder(
        id: id,
        child: Icon(
          Icons.circle,
          color: inputPins[0].value ? Colors.green : Colors.grey,
          size: 25,
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
  void calculateOutput() {}

  @override
  BaseLogicComponent clone() => Output(position: position, id: id);
}
