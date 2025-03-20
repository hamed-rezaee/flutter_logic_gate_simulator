import 'package:flutter/material.dart';
import 'package:flutter_logic_gate_simulator/components/components.dart';

class Encoder extends BaseLogicComponent with PinNamingMixin, TooltipMixin {
  Encoder({required super.id, required super.position}) {
    for (var i = 0; i < 5; i++) {
      inputPins.add(Pin(index: i, component: this));
    }

    for (var i = 0; i < 2; i++) {
      outputPins.add(Pin(index: i, component: this, isOutput: true));
    }

    setupDefaultPinNames(
      inputNames: const ['I0', 'I1', 'I2', 'I3', 'EN'],
      outputNames: ['Y0', 'Y1'],
    );
  }

  @override
  Size get size => const Size(110, 85);

  @override
  String get tooltipTitle => 'Encoder';

  @override
  String get tooltipDescription =>
      'The encoder component encodes a 4-bit input into a 2-bit output.';

  @override
  Map<String, String> get tooltipProperties => {
        'Inputs': inputNames,
        'Outputs': outputNames,
        'Operation':
            'When EN is high, the output is the index of the input value.',
      };

  @override
  Widget build({
    required VoidCallback onInputToggle,
    required void Function(Pin) onPinTap,
    bool isSelected = false,
  }) {
    final componentBuilder = ComponentBuilder(
      id: id,
      child: const ComponentLabel(title: 'Encoder'),
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
  void calculateOutput() {
    if (!inputPins[4].value) {
      outputPins[0].value = false;
      outputPins[1].value = false;

      return;
    }

    var value = 0;

    for (var i = inputPins.length - 1; i >= 0; i--) {
      if (inputPins[i].value) {
        value = i;
        break;
      }
    }

    outputPins[1].value = (value & 0x02) != 0;
    outputPins[0].value = (value & 0x01) != 0;
  }
}
