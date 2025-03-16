import 'package:flutter/material.dart';
import 'package:flutter_logic_gate_simulator/components/components.dart';

class Encoder extends BaseLogicComponent {
  Encoder({required super.id, required super.position}) {
    for (var i = 0; i < 4; i++) {
      inputPins.add(Pin(component: this, isOutput: false, index: i));
    }

    for (var i = 0; i < 2; i++) {
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
      'ENC\n4x2',
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
    final inputIndex = inputPins.indexWhere((pin) => pin.value);

    if (inputIndex == -1) {
      outputPins[1].value = false;
      outputPins[0].value = false;
    } else {
      outputPins[1].value = (inputIndex & 0x2) != 0;
      outputPins[0].value = (inputIndex & 0x1) != 0;
    }
  }

  @override
  BaseLogicComponent clone() => Encoder(position: position, id: id);
}
