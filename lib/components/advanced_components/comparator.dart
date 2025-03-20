import 'package:flutter/material.dart';
import 'package:flutter_logic_gate_simulator/components/components.dart';

class Comparator extends BaseLogicComponent with PinNamingMixin, TooltipMixin {
  Comparator({required super.id, required super.position}) {
    for (var i = 0; i < 4; i++) {
      inputPins.add(Pin(index: i, component: this));
    }

    for (var i = 0; i < 3; i++) {
      outputPins.add(Pin(index: i, isOutput: true, component: this));
    }

    setupDefaultPinNames(
      inputNames: const ['A0', 'A1', 'B0', 'B1'],
      outputNames: ['LT', 'EQ', 'GT'],
    );
  }

  @override
  Size get size => const Size(125, 75);

  @override
  String get tooltipTitle => 'Comparator';

  @override
  String get tooltipDescription =>
      'The comparator component compares two 2-bit inputs.';

  @override
  Map<String, String> get tooltipProperties => {
        'Inputs': inputNames,
        'Outputs': outputNames,
        'Operations': 'LT: A < B, EQ: A == B, GT: A > B',
      };

  @override
  Widget build({
    required VoidCallback onInputToggle,
    required void Function(Pin pin) onPinTap,
    bool isSelected = false,
  }) {
    final componentBuilder = ComponentBuilder(
      id: id,
      child: const ComponentLabel(title: 'Comparator'),
      position: position,
      size: size,
      isSelected: isSelected,
      inputPins: inputPins,
      outputPins: outputPins,
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
  void calculateOutput() {
    final valueA = (inputPins[0].value ? 1 : 0) | (inputPins[1].value ? 2 : 0);
    final valueB = (inputPins[2].value ? 1 : 0) | (inputPins[3].value ? 2 : 0);

    outputPins[0].value = valueA < valueB;
    outputPins[1].value = valueA == valueB;
    outputPins[2].value = valueA > valueB;
  }
}
