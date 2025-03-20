import 'package:flutter/material.dart';
import 'package:flutter_logic_gate_simulator/components/components.dart';

class TFlipFlop extends BaseLogicComponent with PinNamingMixin, TooltipMixin {
  TFlipFlop({required super.id, required super.position}) {
    for (var i = 0; i < 3; i++) {
      inputPins.add(Pin(index: i, component: this));
    }

    for (var i = 0; i < 2; i++) {
      outputPins.add(Pin(index: i, component: this, isOutput: true));
    }

    setupDefaultPinNames(
      inputNames: const ['T', 'CLK', 'RST'],
      outputNames: ['Q', 'Q̅'],
    );
  }

  bool state = false;
  bool previousClock = false;

  @override
  Size get size => const Size(125, 60);

  @override
  String get tooltipTitle => 'T Flip-Flop';

  @override
  String get tooltipDescription =>
      'The T flip-flop component toggles its output on the rising edge of the clock input.';

  @override
  Map<String, String> get tooltipProperties => {
        'Inputs': inputNames,
        'Outputs': outputNames,
        'Operation':
            'When RST is high, the output is reset to 0. When CLK is high, the output is toggled.',
      };

  @override
  Widget build({
    required VoidCallback onInputToggle,
    required void Function(Pin pin) onPinTap,
    bool isSelected = false,
  }) {
    final componentBuilder = ComponentBuilder(
      id: id,
      child: const ComponentLabel(title: 'T\nFlip-Flop'),
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
    final tInput = inputPins[0].value;
    final clockInput = inputPins[1].value;
    final resetInput = inputPins[2].value;

    if (!resetInput) {
      state = false;
    } else if (clockInput && !previousClock) {
      if (tInput) {
        state = !state;
      }
    }

    outputPins[0].value = state;
    outputPins[1].value = !state;

    previousClock = clockInput;
  }
}
