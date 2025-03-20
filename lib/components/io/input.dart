import 'package:flutter/material.dart';
import 'package:flutter_logic_gate_simulator/components/components.dart';

class Input extends BaseLogicComponent with PinNamingMixin, TooltipMixin {
  Input({required super.id, required super.position}) {
    outputPins.add(Pin(index: 0, component: this, isOutput: true));

    setupDefaultPinNames(outputNames: ['Y']);
  }

  bool isOn = false;

  @override
  String get tooltipTitle => 'Input';

  @override
  String get tooltipDescription =>
      'The input component outputs the value of the switch.';

  @override
  Map<String, String> get tooltipProperties => {
        'Inputs': inputNames,
        'Outputs': outputNames,
        'Operation': 'Toggle the switch to change the output value.',
      };

  @override
  Widget build({
    required VoidCallback onInputToggle,
    required void Function(Pin) onPinTap,
    bool isSelected = false,
  }) =>
      ComponentBuilder(
        id: id,
        child: _buildContent(onInputToggle),
        inputPins: inputPins,
        outputPins: outputPins,
        tooltip: tooltip,
        isSelected: isSelected,
        position: position,
        size: size,
        onInputToggle: onInputToggle,
        onPinTap: onPinTap,
      );

  Widget _buildContent(VoidCallback onInputToggle) => GestureDetector(
        onTap: () {
          isOn = !isOn;
          onInputToggle();
        },
        child: Icon(
          Icons.circle,
          color: outputPins[0].value ? Colors.green : Colors.grey,
          size: 25,
        ),
      );

  @override
  void calculateOutput() => outputPins[0].value = isOn;
}
