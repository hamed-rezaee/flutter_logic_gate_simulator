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
    bool isSelected = false,
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
    isSelected: isSelected,
    position: position,
    size: size,
    onInputToggle: onInputToggle,
    onPinTap: onPinTap,
  );

  @override
  void calculateOutput() {
    var value = 0;

    for (var i = inputPins.length - 1; i >= 0; i--) {
      if (inputPins[i].value) {
        value = i;
        break;
      }
    }

    outputPins[1].value = (value & 0x02) != 0;
    outputPins[0].value = (value & 0x01) != 0;
  }

  @override
  BaseLogicComponent clone() => Encoder(position: position, id: id);
}
