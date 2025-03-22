import 'package:flutter/material.dart';
import 'package:flutter_logic_gate_simulator/components/components.dart';

class Clock extends BaseLogicComponent
    with PinNamingMixin, ComponentInformationMixin {
  Clock({required super.id, required super.position}) {
    for (var i = 0; i < 6; i++) {
      inputPins.add(Pin(index: i, component: this));
    }

    for (var i = 0; i < 1; i++) {
      outputPins.add(Pin(index: i, component: this, isOutput: true));
    }

    setupDefaultPinNames(
      inputNames: const ['T0', 'T1', 'T2', 'T3', 'T4', 'EN'],
      outputNames: ['Y'],
    );
  }

  int _counter = 0;

  @override
  Size get size => const Size(90, 100);

  @override
  String get title => 'Clock';

  @override
  String get description =>
      'The clock component outputs a pulse on each rising edge of the clock input.';

  @override
  Map<String, String> get properties => {
        'Inputs': inputNames,
        'Outputs': outputNames,
        'Operation':
            'To adjust the clock frequency, set the input pins to the desired binary value.',
      };

  @override
  Widget build({
    required VoidCallback onInputToggle,
    required void Function(Pin) onPinTap,
    bool isSelected = false,
  }) =>
      ComponentBuilder(
        id: id,
        child: const ComponentLabel(title: 'Clock'),
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
    if (!inputPins[5].value) {
      outputPins[0].value = false;
      _counter = 0;
    } else {
      final counterMultiplier = _binaryToDecimal(inputPins.sublist(0, 5));

      if (_counter > counterMultiplier) {
        outputPins[0].value = !outputPins[0].value;
        _counter = 0;
      }

      _counter++;
    }
  }

  int _binaryToDecimal(List<Pin> input) {
    var result = 0;

    for (var i = input.length - 1; i >= 0; i--) {
      if (input[i].value) {
        result += 1 << i;
      }
    }

    return result;
  }
}
