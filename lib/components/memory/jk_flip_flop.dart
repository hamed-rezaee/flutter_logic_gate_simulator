import 'package:flutter/material.dart';
import 'package:flutter_logic_gate_simulator/components/components.dart';

class JKFlipFlop extends BaseLogicComponent
    with PinNamingMixin, ComponentInformationMixin {
  JKFlipFlop({required super.id, required super.position}) {
    for (var i = 0; i < 4; i++) {
      inputPins.add(Pin(index: i, component: this));
    }

    for (var i = 0; i < 2; i++) {
      outputPins.add(Pin(index: i, component: this, isOutput: true));
    }

    setupDefaultPinNames(
      inputNames: const ['J', 'K', 'CLK', 'RST'],
      outputNames: ['Q', 'Q̅'],
    );
  }

  bool state = false;
  bool _previousClock = false;

  @override
  Size get size => const Size(125, 60);

  @override
  String get title => 'JK Flip-Flop';

  @override
  String get description =>
      'The JK flip-flop component stores a single bit of data.';

  @override
  Map<String, String> get properties => {
        'Inputs': inputNames,
        'Outputs': outputNames,
        'Operation':
            'When RST is high, the output is reset to 0. When CLK is high, the output is set to the value of J or K.',
      };

  @override
  Widget build({
    required VoidCallback onInputToggle,
    required void Function(Pin) onPinTap,
    bool isSelected = false,
  }) =>
      ComponentBuilder(
        id: id,
        child: const ComponentLabel(title: 'JK\nFlip-Flop'),
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
    final jInput = inputPins[0].value;
    final kInput = inputPins[1].value;
    final clockInput = inputPins[2].value;
    final resetInput = inputPins[3].value;

    if (!resetInput) {
      state = false;
    } else if (clockInput && !_previousClock) {
      if (jInput && kInput) {
        state = !state;
      } else if (jInput) {
        state = true;
      } else if (kInput) {
        state = false;
      }
    }

    outputPins[0].value = state;
    outputPins[1].value = !state;

    _previousClock = clockInput;
  }
}
