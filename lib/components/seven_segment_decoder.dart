import 'package:flutter/material.dart';
import 'package:flutter_logic_gate_simulator/components/components.dart';

class SevenSegmentDecoder extends BaseLogicComponent {
  SevenSegmentDecoder({required super.id, required super.position}) {
    for (var i = 0; i < 4; i++) {
      inputPins.add(Pin(component: this, isOutput: false, index: i));
    }

    for (var i = 0; i < 7; i++) {
      outputPins.add(Pin(component: this, isOutput: true, index: i));
    }
  }

  @override
  Size get size => const Size(80, 110);

  @override
  Widget build({
    required VoidCallback onInputToggle,
    required void Function(Pin) onPinTap,
  }) => ComponentBuilder(
    id: id,
    child: const Text(
      '7 SEG DEC',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
    ),
    inputPins: inputPins,
    outputPins: outputPins,
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

  @override
  BaseLogicComponent clone() => SevenSegmentDecoder(position: position, id: id);
}
