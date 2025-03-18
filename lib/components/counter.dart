import 'package:flutter/material.dart';
import 'package:flutter_logic_gate_simulator/components/base_logic_component.dart';
import 'package:flutter_logic_gate_simulator/components/component_builder.dart';
import 'package:flutter_logic_gate_simulator/components/pin.dart';

class Counter extends BaseLogicComponent {
  Counter({required super.id, required super.position}) {
    inputPins
      ..add(Pin(index: 0, isOutput: false, component: this))
      ..add(Pin(index: 1, isOutput: false, component: this));

    for (var i = 0; i < 4; i++) {
      outputPins.add(Pin(index: i, isOutput: true, component: this));
    }

    _resetCounter();
  }

  int _count = 0;
  bool _lastClockState = false;

  @override
  Size get size => const Size(100, 80);

  @override
  Widget build({
    required VoidCallback onInputToggle,
    required void Function(Pin pin) onPinTap,
    bool isSelected = false,
  }) => ComponentBuilder(
    id: id,
    child: const Text(
      'COUNTER',
      textAlign: TextAlign.center,
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
    if (inputPins[1].value) {
      _resetCounter();
      _updateOutputPins();
      return;
    }

    final clockValue = inputPins[0].value;
    if (clockValue && !_lastClockState) {
      _increment();
      _updateOutputPins();
    }

    _lastClockState = clockValue;
  }

  void _resetCounter() {
    _count = 0;
    _updateOutputPins();
  }

  void _increment() {
    _count = (_count + 1) % 16;
  }

  void _updateOutputPins() {
    for (var i = 0; i < 4; i++) {
      outputPins[i].value = (_count & (1 << i)) != 0;
    }
  }

  @override
  BaseLogicComponent clone() => Counter(id: id, position: position);
}
