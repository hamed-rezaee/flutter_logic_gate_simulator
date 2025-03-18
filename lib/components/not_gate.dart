import 'package:flutter/material.dart';
import 'package:flutter_logic_gate_simulator/components/components.dart';

class NotGate extends BaseLogicComponent {
  NotGate({required super.id, required super.position}) {
    inputPins.add(Pin(component: this, isOutput: false, index: 0));

    outputPins.add(Pin(component: this, isOutput: true, index: 0));
  }

  @override
  Widget build({
    required VoidCallback onInputToggle,
    required void Function(Pin) onPinTap,
    bool isSelected = false,
  }) =>
      ComponentBuilder(
        id: id,
        child: const LogicGate(gateType: LogicGateType.not),
        inputPins: inputPins,
        outputPins: outputPins,
        isSelected: isSelected,
        position: position,
        size: size,
        onInputToggle: onInputToggle,
        onPinTap: onPinTap,
      );

  @override
  void calculateOutput() => outputPins[0].value = !inputPins[0].value;

  @override
  BaseLogicComponent clone() => NotGate(position: position, id: id);
}
