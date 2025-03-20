import 'package:flutter/material.dart';
import 'package:flutter_logic_gate_simulator/components/components.dart';

class AndGate extends BaseLogicComponent with PinNamingMixin, TooltipMixin {
  AndGate({required super.id, required super.position}) {
    for (var i = 0; i < 2; i++) {
      inputPins.add(Pin(index: i, component: this));
    }

    outputPins.add(Pin(index: 0, component: this, isOutput: true));

    setupDefaultPinNames(inputNames: const ['A', 'B'], outputNames: ['Y']);
  }

  @override
  String get tooltipTitle => 'AND Gate';

  @override
  String get tooltipDescription =>
      'The AND gate component outputs true if both inputs are true.';

  @override
  Map<String, String> get tooltipProperties => {
        'Inputs': inputNames,
        'Outputs': outputNames,
        'Operation': 'Y = A AND B',
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
        gateType: LogicGateType.and,
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
      outputPins[0].value = inputPins[0].value && inputPins[1].value;
}
