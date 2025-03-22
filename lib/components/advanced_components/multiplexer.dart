import 'package:flutter/material.dart';
import 'package:flutter_logic_gate_simulator/components/components.dart';

class Multiplexer extends BaseLogicComponent
    with PinNamingMixin, ComponentInformationMixin {
  Multiplexer({required super.id, required super.position}) {
    for (var i = 0; i < 6; i++) {
      inputPins.add(Pin(index: i, component: this));
    }

    outputPins.add(Pin(index: 0, isOutput: true, component: this));

    setupDefaultPinNames(
      inputNames: const ['I0', 'I1', 'I2', 'I3', 'S0', 'S1'],
      outputNames: ['Y'],
    );
  }

  @override
  Size get size => const Size(100, 110);

  @override
  String get title => 'Multiplexer';

  @override
  String get description =>
      'The multiplexer component selects one of the input values based on the select inputs.';

  @override
  Map<String, String> get properties => {
        'Inputs': inputNames,
        'Outputs': outputNames,
        'Operation':
            'S0 and S1 are used to select the input value and output it.',
      };

  @override
  Widget build({
    required VoidCallback onInputToggle,
    required void Function(Pin pin) onPinTap,
    bool isSelected = false,
  }) =>
      ComponentBuilder(
        id: id,
        child: const ComponentLabel(title: 'Mux'),
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
  void calculateOutput() {
    final s0 = inputPins[4].value;
    final s1 = inputPins[5].value;

    final selectedInput = (s1 ? 2 : 0) | (s0 ? 1 : 0);

    selectedInput < 4
        ? outputPins[0].value = inputPins[selectedInput].value
        : outputPins[0].value = false;
  }
}
