import 'package:flutter/material.dart';
import 'package:flutter_logic_gate_simulator/components/components.dart';

class DFlipFlop extends BaseLogicComponent
    with PinNamingMixin, ComponentInformationMixin {
  DFlipFlop({required super.id, required super.position}) {
    for (var i = 0; i < 3; i++) {
      inputPins.add(Pin(index: i, component: this));
    }

    for (var i = 0; i < 2; i++) {
      outputPins.add(Pin(index: i, component: this, isOutput: true));
    }

    setupDefaultPinNames(
      inputNames: const ['D', 'CLK', 'RST'],
      outputNames: ['Q', 'Q̅'],
    );
  }

  bool state = false;
  bool previousClock = false;

  @override
  Size get size => const Size(125, 60);

  @override
  String get title => 'D Flip-Flop';

  @override
  String get description =>
      'The D flip-flop component stores the value of the D input on the rising edge of the clock input.';

  @override
  Map<String, String> get properties => {
        'Inputs': inputNames,
        'Outputs': outputNames,
        'Operation':
            'When RST is high, the output is reset to 0. When CLK is high, the output is set to the value of D.',
      };

  @override
  Widget build({
    required VoidCallback onInputToggle,
    required void Function(Pin pin) onPinTap,
    bool isSelected = false,
  }) =>
      ComponentBuilder(
        id: id,
        child: const ComponentLabel(title: 'D\nFlip-Flop'),
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
    final dInput = inputPins[0].value;
    final clockInput = inputPins[1].value;
    final resetInput = inputPins[2].value;

    if (!resetInput) {
      state = false;
    } else if (clockInput && !previousClock) {
      state = dInput;
    }

    outputPins[0].value = state;
    outputPins[1].value = !state;

    previousClock = clockInput;
  }
}
