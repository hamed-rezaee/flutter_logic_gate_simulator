import 'package:flutter/material.dart';
import 'package:flutter_logic_gate_simulator/components/components.dart';

class NotGate extends BaseLogicComponent with PinNamingMixin, TooltipMixin {
  NotGate({required super.id, required super.position}) {
    inputPins.add(Pin(index: 0, component: this));

    outputPins.add(Pin(index: 0, component: this, isOutput: true));

    setupDefaultPinNames(inputNames: const ['A'], outputNames: ['Y']);
  }

  @override
  String get tooltipTitle => 'NOT Gate';

  @override
  String get tooltipDescription =>
      'The NOT gate component outputs the opposite of the input.';

  @override
  Map<String, String> get tooltipProperties => {
        'Inputs': inputNames,
        'Outputs': outputNames,
        'Operation': 'Y = NOT A',
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
          gateType: LogicGateType.not,
          gateColor: Colors.grey[400]!,
        ),
        inputPins: inputPins,
        outputPins: outputPins,
        tooltip: tooltip,
        isSelected: isSelected,
        position: position,
        size: size,
        onInputToggle: onInputToggle,
        onPinTap: onPinTap,
      );

  @override
  void calculateOutput() => outputPins[0].value = !inputPins[0].value;
}
