import 'package:flutter/material.dart';
import 'package:flutter_logic_gate_simulator/components/components.dart';

class SRFlipFlop extends BaseLogicComponent {
  SRFlipFlop({required super.id, required super.position}) {
    for (var i = 0; i < 4; i++) {
      inputPins.add(Pin(component: this, isOutput: false, index: i));
    }

    for (var i = 0; i < 2; i++) {
      outputPins.add(Pin(component: this, isOutput: true, index: i));
    }
  }

  bool state = false;
  bool previousClock = false;

  @override
  Size get size => const Size(80, 80);

  @override
  Widget build({
    required VoidCallback onInputToggle,
    required void Function(Pin pin) onPinTap,
  }) => ComponentBuilder(
    id: id,
    child: const Text(
      'SR FF',
      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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

  @override
  BaseLogicComponent clone() => SRFlipFlop(id: id, position: position);
}
