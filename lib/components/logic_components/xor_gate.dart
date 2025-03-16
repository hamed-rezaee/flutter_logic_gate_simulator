import 'package:flutter/material.dart';
import 'package:flutter_logic_gate_simulator/components/component_builder.dart';
import 'package:flutter_logic_gate_simulator/components/logic_components/base_logic_component.dart';
import 'package:flutter_logic_gate_simulator/components/pin.dart';
import 'package:flutter_logic_gate_simulator/widgets/gate_painter.dart';

class XorGate extends BaseLogicComponent {
  XorGate({required super.id, required super.position}) {
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
    child: const LogicGateView(gateType: LogicGateType.xor),
    inputPins: inputPins,
    outputPins: outputPins,
    position: position,
    size: size,
    onInputToggle: onInputToggle,
    onPinTap: onPinTap,
  );

  @override
  void calculateOutput() =>
      outputPins[0].value = inputPins[0].value != inputPins[1].value;

  @override
  BaseLogicComponent clone() => XorGate(position: position, id: id);
}
