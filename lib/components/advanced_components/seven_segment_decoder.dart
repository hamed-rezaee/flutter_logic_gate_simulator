import 'package:flutter/material.dart';
import 'package:flutter_logic_gate_simulator/components/components.dart';

class SevenSegmentDecoder extends BaseLogicComponent
    with PinNamingMixin, TooltipMixin {
  SevenSegmentDecoder({required super.id, required super.position}) {
    for (var i = 0; i < 4; i++) {
      inputPins.add(Pin(index: i, component: this));
    }

    for (var i = 0; i < 7; i++) {
      outputPins.add(Pin(index: i, component: this, isOutput: true));
    }

    setupDefaultPinNames(
      inputNames: const ['A', 'B', 'C', 'D'],
      outputNames: ['A', 'B', 'C', 'D', 'E', 'F', 'G'],
    );
  }

  @override
  Size get size => const Size(110, 115);

  @override
  String get tooltipTitle => '7-Segment Decoder';

  @override
  String get tooltipDescription =>
      'The 7-segment decoder component decodes a 4-bit input into a 7-bit output.';

  @override
  Map<String, String> get tooltipProperties => {
        'Inputs': inputNames,
        'Outputs': outputNames,
        'Operation': 'The output is the 7-segment pattern of the input value.',
      };

  @override
  Widget build({
    required VoidCallback onInputToggle,
    required void Function(Pin) onPinTap,
    bool isSelected = false,
  }) =>
      ComponentBuilder(
        id: id,
        child: const ComponentLabel(title: '7-Segment Decoder'),
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
    var binaryValue = 0;

    for (var i = 0; i < inputPins.length; i++) {
      if (inputPins[i].value) {
        binaryValue += 1 << i;
      }
    }

    final segmentPatterns = <List<bool>>[
      [true, true, true, true, true, true, false],
      [false, true, true, false, false, false, false],
      [true, true, false, true, true, false, true],
      [true, true, true, true, false, false, true],
      [false, true, true, false, false, true, true],
      [true, false, true, true, false, true, true],
      [true, false, true, true, true, true, true],
      [true, true, true, false, false, false, false],
      [true, true, true, true, true, true, true],
      [true, true, true, true, false, true, true],
      [true, true, true, false, true, true, true],
      [false, false, true, true, true, true, true],
      [true, false, false, true, true, true, false],
      [false, true, true, true, true, false, true],
      [true, false, false, true, true, true, true],
      [true, false, false, false, true, true, true],
    ];

    binaryValue = binaryValue.clamp(0, 15);

    for (var i = 0; i < 7; i++) {
      outputPins[i].value = segmentPatterns[binaryValue][i];
    }
  }
}
