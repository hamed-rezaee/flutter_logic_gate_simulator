import 'package:flutter/material.dart';
import 'package:flutter_logic_gate_simulator/components/components.dart';

class XorGate extends BaseLogicComponent
    with PinNamingMixin, ComponentInformationMixin {
  XorGate({required super.id, required super.position}) {
    for (var i = 0; i < 2; i++) {
      inputPins.add(Pin(index: i, component: this));
    }

    outputPins.add(Pin(index: 0, component: this, isOutput: true));

    setupDefaultPinNames(inputNames: const ['A', 'B'], outputNames: ['Y']);
  }

  @override
  String get title => 'XOR Gate';

  @override
  String get description =>
      'The XOR gate component outputs true if the inputs are different.';

  @override
  Map<String, String> get properties => {
        'Inputs': inputNames,
        'Outputs': outputNames,
        'Operation': 'Y = A XOR B',
      };

  @override
  Widget build({
    required VoidCallback onInputToggle,
    required void Function(Pin) onPinTap,
    bool isSelected = false,
  }) =>
      ComponentBuilder(
        id: id,
        child: LogicGate(
          gateType: LogicGateType.xor,
          gateColor: Colors.grey[400]!,
        ),
        inputPins: inputPins,
        outputPins: outputPins,
        information: information,
        isSelected: isSelected,
        position: position,
        size: size,
        onInputToggle: onInputToggle,
        onPinTap: onPinTap,
      );

  @override
  void calculateOutput() =>
      outputPins[0].value = inputPins[0].value != inputPins[1].value;
}
