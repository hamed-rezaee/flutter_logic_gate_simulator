import 'package:flutter/material.dart';
import 'package:flutter_logic_gate_simulator/components/components.dart';

class Decoder extends BaseLogicComponent {
  Decoder({required super.id, required super.position}) {
    for (var i = 0; i < 2; i++) {
      inputPins.add(Pin(component: this, isOutput: false, index: i));
    }

    for (var i = 0; i < 4; i++) {
      outputPins.add(Pin(component: this, isOutput: true, index: i));
    }
  }

  @override
  Size get size => const Size(80, 80);

  @override
  Widget build({
    required VoidCallback onInputToggle,
    required void Function(Pin) onPinTap,
  }) => ComponentBuilder(
    id: id,
    child: const Text(
      'DEC\n2x4',
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
    final a0 = inputPins[0].value ? 1 : 0;
    final a1 = inputPins[1].value ? 1 : 0;
    final index = (a1 << 1) | a0;

    for (var i = 0; i < outputPins.length; i++) {
      outputPins[i].value = i == index;
    }
  }

  @override
  BaseLogicComponent clone() => Decoder(position: position, id: id);
}
