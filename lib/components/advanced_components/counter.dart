import 'package:flutter/material.dart';
import 'package:flutter_logic_gate_simulator/components/components.dart';

class Counter extends BaseLogicComponent with PinNamingMixin, TooltipMixin {
  Counter({required super.id, required super.position}) {
    for (var i = 0; i < 2; i++) {
      inputPins.add(Pin(index: i, component: this));
    }

    for (var i = 0; i < 4; i++) {
      outputPins.add(Pin(index: i, isOutput: true, component: this));
    }

    setupDefaultPinNames(
      inputNames: const ['CLK', 'RST'],
      outputNames: ['Y0', 'Y1', 'Y2', 'Y3'],
    );
  }

  int _count = 0;
  bool _lastClockState = false;

  @override
  Size get size => const Size(110, 70);

  @override
  String get tooltipTitle => 'Counter';

  @override
  String get tooltipDescription =>
      'The counter component increments its output by 1 on each rising edge of the clock input.';

  @override
  Map<String, String> get tooltipProperties => {
        'Inputs': 'CLK, RST',
        'Outputs': 'Y0, Y1, Y2, Y3',
      };

  @override
  Widget build({
    required VoidCallback onInputToggle,
    required void Function(Pin pin) onPinTap,
    bool isSelected = false,
  }) {
    final componentBuilder = ComponentBuilder(
      id: id,
      child: const ComponentLabel(title: 'Counter'),
      inputPins: inputPins,
      outputPins: outputPins,
      isSelected: isSelected,
      position: position,
      size: size,
      onInputToggle: onInputToggle,
      onPinTap: onPinTap,
    );

    return buildWithTooltip(
      child: componentBuilder,
      onInputToggle: onInputToggle,
      onPinTap: onPinTap,
      isSelected: isSelected,
    );
  }

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

  void _increment() => _count = (_count + 1) % 16;

  void _updateOutputPins() {
    for (var i = 0; i < 4; i++) {
      outputPins[i].value = (_count & (1 << i)) != 0;
    }
  }
}
