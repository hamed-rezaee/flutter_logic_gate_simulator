import 'package:flutter/material.dart';
import 'package:flutter_logic_gate_simulator/components/components.dart';

class NorGate extends BaseLogicComponent
    with PinNamingMixin, ComponentInformationMixin {
  NorGate({required super.id, required super.position}) {
    for (var i = 0; i < 2; i++) {
      inputPins.add(Pin(index: i, component: this));
    }

    outputPins.add(Pin(index: 0, component: this, isOutput: true));

    setupDefaultPinNames(inputNames: const ['A', 'B'], outputNames: ['Y']);
  }

  @override
  String get title => 'NOR Gate';

  @override
  String get description =>
      'The NOR gate component outputs true if both inputs are false.';

  @override
  Map<String, String> get properties => {
        'Inputs': inputNames,
        'Outputs': outputNames,
        'Operation': 'Y = NOT (A OR B)',
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
          gateType: LogicGateType.nor,
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
      outputPins[0].value = !(inputPins[0].value || inputPins[1].value);
}
