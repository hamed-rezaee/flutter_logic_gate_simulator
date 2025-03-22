import 'package:flutter/material.dart';
import 'package:flutter_logic_gate_simulator/components/components.dart';

class Output extends BaseLogicComponent
    with PinNamingMixin, ComponentInformationMixin {
  Output({required super.id, required super.position}) {
    inputPins.add(Pin(index: 0, component: this));

    setupDefaultPinNames(inputNames: const ['A']);
  }

  @override
  String get title => 'Output';

  @override
  String get description => 'The output component outputs the input value.';

  @override
  Map<String, String> get properties => {
        'Inputs': inputNames,
        'Outputs': outputNames,
        'Operation': 'Y = A',
      };

  @override
  Widget build({
    required VoidCallback onInputToggle,
    required void Function(Pin) onPinTap,
    bool isSelected = false,
  }) =>
      ComponentBuilder(
        id: id,
        child: _buildContent(),
        inputPins: inputPins,
        outputPins: outputPins,
        information: information,
        isSelected: isSelected,
        position: position,
        size: size,
        onInputToggle: onInputToggle,
        onPinTap: onPinTap,
      );

  Widget _buildContent() => Icon(
        Icons.circle,
        color: inputPins[0].value ? Colors.green : Colors.grey,
        size: 25,
      );

  @override
  void calculateOutput() {}
}
