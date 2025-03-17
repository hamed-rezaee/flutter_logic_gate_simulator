import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_logic_gate_simulator/components/components.dart';

class Clock extends BaseLogicComponent {
  Clock({required super.id, required super.position}) {
    inputPins.add(Pin(component: this, isOutput: false, index: 0));

    outputPins.add(Pin(component: this, isOutput: true, index: 0));
  }

  final Duration _interval = const Duration(seconds: 1);

  Timer? _timer;

  @override
  Widget build({
    required VoidCallback onInputToggle,
    required void Function(Pin) onPinTap,
    bool isSelected = false,
  }) => ComponentBuilder(
    id: id,
    child: StatefulBuilder(
      builder: (context, setState) {
        setState(() {
          inputPins[0].value ? _startClock(onInputToggle) : _stopClock();
        });

        return const Icon(Icons.timer_sharp, color: Colors.white, size: 30);
      },
    ),
    inputPins: inputPins,
    outputPins: outputPins,
    isSelected: isSelected,
    position: position,
    size: size,
    onInputToggle: onInputToggle,
    onPinTap: onPinTap,
  );

  void _startClock(VoidCallback onInputToggle) {
    _timer?.cancel();

    _timer = Timer.periodic(_interval, (timer) {
      outputPins[0].value = !outputPins[0].value;
      onInputToggle();
    });
  }

  void _stopClock() {
    outputPins[0].value = false;

    _timer?.cancel();
    _timer = null;
  }

  @override
  void calculateOutput() {}

  @override
  BaseLogicComponent clone() => Clock(position: position, id: id);

  @override
  void dispose() => _stopClock();
}
