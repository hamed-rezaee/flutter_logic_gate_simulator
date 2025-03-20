import 'package:flutter/material.dart';
import 'package:flutter_logic_gate_simulator/components/components.dart';

class Adder extends BaseLogicComponent with PinNamingMixin, TooltipMixin {
  Adder({required super.id, required super.position}) {
    for (var i = 0; i < 3; i++) {
      inputPins.add(Pin(index: i, component: this));
    }

    for (var i = 0; i < 2; i++) {
      outputPins.add(Pin(index: i, component: this, isOutput: true));
    }

    setupDefaultPinNames(
      inputNames: ['A', 'B', 'Cin'],
      outputNames: ['S', 'Cout'],
    );
  }

  @override
  Size get size => const Size(110, 65);

  @override
  String get tooltipTitle => 'Adder';

  @override
  String get tooltipDescription =>
      'The adder component adds two 1-bit inputs and a carry input.';

  @override
  Map<String, String> get tooltipProperties => {
        'Inputs': inputNames,
        'Outputs': outputNames,
        'Operation':
            'S = A XOR B XOR Cin, Cout = (A AND B) OR (A AND Cin) OR (B AND Cin)',
      };

  @override
  Widget build({
    required VoidCallback onInputToggle,
    required void Function(Pin pin) onPinTap,
    bool isSelected = false,
  }) =>
      ComponentBuilder(
        id: id,
        child: const ComponentLabel(title: 'Adder'),
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
  void calculateOutput() {
    final sum = inputPins[0].value ^ inputPins[1].value ^ inputPins[2].value;
    final carryOut = (inputPins[0].value && inputPins[1].value) ||
        (inputPins[0].value && inputPins[2].value) ||
        (inputPins[1].value && inputPins[2].value);

    outputPins[0].value = sum;
    outputPins[1].value = carryOut;
  }
}
