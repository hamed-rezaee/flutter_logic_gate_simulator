import 'package:flutter/material.dart';
import 'package:flutter_logic_gate_simulator/components/components.dart';

class OrGate extends BaseLogicComponent with PinNamingMixin, TooltipMixin {
  OrGate({required super.id, required super.position}) {
    for (var i = 0; i < 2; i++) {
      inputPins.add(Pin(index: i, component: this));
    }

    outputPins.add(Pin(index: 0, component: this, isOutput: true));

    setupDefaultPinNames(inputNames: const ['A', 'B'], outputNames: ['Y']);
  }

  @override
  String get tooltipTitle => 'OR Gate';

  @override
  String get tooltipDescription =>
      'The OR gate component outputs true if at least one input is true.';

  @override
  Map<String, String> get tooltipProperties => {
        'Inputs': inputNames,
        'Outputs': outputNames,
        'Operation': 'Y = A OR B',
      };

  @override
  Widget build({
    required VoidCallback onInputToggle,
    required void Function(Pin) onPinTap,
    bool isSelected = false,
  }) {
    final componentBuilder = ComponentBuilder(
      id: id,
      child: LogicGate(
        gateType: LogicGateType.or,
        gateColor: Colors.grey[400]!,
      ),
      inputPins: inputPins,
      outputPins: outputPins,
      isSelected: isSelected,
      position: position,
      size: size,
      onInputToggle: onInputToggle,
      onPinTap: onPinTap,
    );

    return buildWithTooltip(
      child: componentBuilder,
      onInputToggle: onInputToggle,
      onPinTap: onPinTap,
      isSelected: isSelected,
    );
  }

  @override
  void calculateOutput() =>
      outputPins[0].value = inputPins[0].value || inputPins[1].value;
}
