import 'package:flutter/material.dart';
import 'package:flutter_logic_gate_simulator/components/components.dart';

class Clock extends BaseLogicComponent {
  Clock({required super.id, required super.position}) {
    for (var i = 0; i < 6; i++) {
      inputPins.add(Pin(component: this, isOutput: false, index: i));
    }

    for (var i = 0; i < 1; i++) {
      outputPins.add(Pin(component: this, isOutput: true, index: i));
    }
  }

  int _counter = 0;

  @override
  Size get size => const Size(80, 110);

  @override
  Widget build({
    required VoidCallback onInputToggle,
    required void Function(Pin) onPinTap,
    bool isSelected = false,
  }) =>
      ComponentBuilder(
        id: id,
        child: const Text(
          'CLOCK',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        inputPins: inputPins,
        outputPins: outputPins,
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

  @override
  BaseLogicComponent clone() => Clock(position: position, id: id);

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
