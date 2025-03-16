import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_logic_gate_simulator/components/components.dart';

class Clock extends BaseLogicComponent {
  Clock({required super.id, required super.position}) {
    outputPins.add(Pin(component: this, isOutput: true, index: 0));
  }

  final Duration _interval = const Duration(seconds: 1);

  bool isOn = false;
  bool isRunning = false;

  Timer? _timer;

  @override
  Size get size => const Size(80, 90);

  @override
  Widget build({
    required VoidCallback onInputToggle,
    required void Function(Pin) onPinTap,
  }) => ComponentBuilder(
    id: id,
    child: StatefulBuilder(
      builder:
          (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(
                  Icons.timer_sharp,
                  color: isOn ? Colors.green : Colors.grey,
                  size: 30,
                ),
              ),
              Transform.scale(
                scale: 0.7,
                child: Switch(
                  value: isRunning,
                  activeColor: Colors.green,
                  onChanged: (value) {
                    isRunning = value;
                    isRunning ? _startClock(onInputToggle) : _stopClock();
                    setState(() {});
                  },
                ),
              ),
            ],
          ),
    ),
    inputPins: inputPins,
    outputPins: outputPins,
    position: position,
    size: size,
    onInputToggle: onInputToggle,
    onPinTap: onPinTap,
  );

  void _startClock(VoidCallback onInputToggle) {
    _timer?.cancel();
    _timer = Timer.periodic(_interval, (timer) {
      isOn = !isOn;
      onInputToggle();
    });
  }

  @override
  void calculateOutput() => outputPins[0].value = isOn;

  @override
  BaseLogicComponent clone() => Clock(position: position, id: id);

  void _stopClock() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() => _stopClock();
}
