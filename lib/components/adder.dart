import 'package:flutter/material.dart';
import 'package:flutter_logic_gate_simulator/components/components.dart';

class Adder extends BaseLogicComponent {
  Adder({required super.id, required super.position}) {
    for (var i = 0; i < 5; i++) {
      inputPins.add(Pin(component: this, isOutput: false, index: i));
    }

    for (var i = 0; i < 3; i++) {
      outputPins.add(Pin(component: this, isOutput: true, index: i));
    }
  }

  @override
  Size get size => const Size(80, 95);

  @override
  Widget build({
    required VoidCallback onInputToggle,
    required void Function(Pin pin) onPinTap,
  }) => ComponentBuilder(
    id: id,
    child: const Text(
      'ADDER',
      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      textAlign: TextAlign.center,
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
    final aInputs = inputPins.sublist(0, 2).map((pin) => pin.value).toList();
    final bInputs = inputPins.sublist(2, 4).map((pin) => pin.value).toList();
    final carryIn = inputPins[4].value;
    final sumOutputs = List<bool>.filled(2, false);

    var carry = carryIn;

    for (var i = 0; i < 2; i++) {
      final a = aInputs[i];
      final b = bInputs[i];

      sumOutputs[i] = a ^ b ^ carry;

      carry = (a && b) || (a && carry) || (b && carry);
    }

    for (var i = 0; i < 2; i++) {
      outputPins[i].value = sumOutputs[i];
    }

    outputPins[2].value = carry;
  }

  @override
  BaseLogicComponent clone() => Adder(id: id, position: position);
}
