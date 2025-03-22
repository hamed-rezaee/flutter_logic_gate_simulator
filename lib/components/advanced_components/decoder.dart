import 'package:flutter/material.dart';
import 'package:flutter_logic_gate_simulator/components/components.dart';

class Decoder extends BaseLogicComponent
    with PinNamingMixin, ComponentInformationMixin {
  Decoder({required super.id, required super.position}) {
    for (var i = 0; i < 3; i++) {
      inputPins.add(Pin(index: i, component: this));
    }

    for (var i = 0; i < 4; i++) {
      outputPins.add(Pin(index: i, component: this, isOutput: true));
    }

    setupDefaultPinNames(
      inputNames: const ['A0', 'A1', 'EN'],
      outputNames: ['Y0', 'Y1', 'Y2', 'Y3'],
    );
  }

  @override
  Size get size => const Size(110, 85);

  @override
  String get title => 'Decoder';

  @override
  String get description =>
      'The decoder component decodes a 2-bit input into a 4-bit output.';

  @override
  Map<String, String> get properties => {
        'Inputs': inputNames,
        'Outputs': outputNames,
        'Operation':
            'When EN is high, the output is 1 at the index of the input value.',
      };

  @override
  Widget build({
    required VoidCallback onInputToggle,
    required void Function(Pin) onPinTap,
    bool isSelected = false,
  }) =>
      ComponentBuilder(
        id: id,
        child: const ComponentLabel(title: 'Decoder'),
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
    if (!inputPins[2].value) {
      for (final outputPin in outputPins) {
        outputPin.value = false;
      }

      return;
    }

    final a0 = inputPins[0].value ? 1 : 0;
    final a1 = inputPins[1].value ? 1 : 0;
    final index = (a1 << 1) | a0;

    for (var i = 0; i < outputPins.length; i++) {
      outputPins[i].value = i == index;
    }
  }
}
