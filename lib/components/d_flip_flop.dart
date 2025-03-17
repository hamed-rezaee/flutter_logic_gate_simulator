import 'package:flutter/material.dart';
import 'package:flutter_logic_gate_simulator/components/components.dart';

class DFlipFlop extends BaseLogicComponent {
  DFlipFlop({required super.id, required super.position}) {
    for (var i = 0; i < 3; i++) {
      inputPins.add(Pin(component: this, isOutput: false, index: i));
    }

    for (var i = 0; i < 2; i++) {
      outputPins.add(Pin(component: this, isOutput: true, index: i));
    }
  }

  bool state = false;
  bool previousClock = false;

  @override
  Size get size => const Size(80, 65);

  @override
  Widget build({
    required VoidCallback onInputToggle,
    required void Function(Pin pin) onPinTap,
  }) => ComponentBuilder(
    id: id,
    child: const Text(
      'D FF',
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

  @override
  BaseLogicComponent clone() => DFlipFlop(id: id, position: position);
}
