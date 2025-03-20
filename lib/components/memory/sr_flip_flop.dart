import 'package:flutter/material.dart';
import 'package:flutter_logic_gate_simulator/components/components.dart';

class SRFlipFlop extends BaseLogicComponent with PinNamingMixin, TooltipMixin {
  SRFlipFlop({required super.id, required super.position}) {
    for (var i = 0; i < 4; i++) {
      inputPins.add(Pin(index: i, component: this));
    }

    for (var i = 0; i < 2; i++) {
      outputPins.add(Pin(index: i, component: this, isOutput: true));
    }

    setupDefaultPinNames(
      inputNames: const ['S', 'R', 'CLK', 'RST'],
      outputNames: ['Q', 'Q̅'],
    );
  }

  bool state = false;
  bool previousClock = false;

  @override
  Size get size => const Size(125, 60);

  @override
  String get tooltipTitle => 'SR Flip-Flop';

  @override
  String get tooltipDescription =>
      'The SR flip-flop component stores a single bit of data.';

  @override
  Map<String, String> get tooltipProperties => {
        'Inputs': inputNames,
        'Outputs': outputNames,
        'Operation':
            'When RST is high, the output is reset to 0. When CLK is high, the output is set to the value of S or R.',
      };

  @override
  Widget build({
    required VoidCallback onInputToggle,
    required void Function(Pin pin) onPinTap,
    bool isSelected = false,
  }) =>
      ComponentBuilder(
        id: id,
        child: const ComponentLabel(title: 'SR\nFlip-Flop'),
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
    final sInput = inputPins[0].value;
    final rInput = inputPins[1].value;
    final clockInput = inputPins[2].value;
    final resetInput = inputPins[3].value;

    if (!resetInput) {
      state = false;
    } else if (clockInput && !previousClock) {
      if (sInput && rInput) {
      } else if (sInput) {
        state = true;
      } else if (rInput) {
        state = false;
      }
    }

    outputPins[0].value = state;
    outputPins[1].value = !state;

    previousClock = clockInput;
  }
}
