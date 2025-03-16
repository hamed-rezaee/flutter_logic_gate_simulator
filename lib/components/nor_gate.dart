import 'package:flutter/material.dart';
import 'package:flutter_logic_gate_simulator/components/components.dart';

class NorGate extends BaseLogicComponent {
  NorGate({required super.id, required super.position}) {
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
    child: const LogicGate(gateType: LogicGateType.nor),
    inputPins: inputPins,
    outputPins: outputPins,
    position: position,
    size: size,
    onInputToggle: onInputToggle,
    onPinTap: onPinTap,
  );

  @override
  void calculateOutput() =>
      outputPins[0].value = !(inputPins[0].value || inputPins[1].value);

  @override
  BaseLogicComponent clone() => NorGate(position: position, id: id);
}
