import 'package:flutter/material.dart';
import 'package:flutter_logic_gate_simulator/components/components.dart';

class Register extends BaseLogicComponent with PinNamingMixin, TooltipMixin {
  Register({required super.id, required super.position}) {
    for (var i = 0; i < 8; i++) {
      inputPins.add(Pin(index: i, component: this));
    }

    for (var i = 0; i < 4; i++) {
      outputPins.add(Pin(index: i, component: this, isOutput: true));
    }

    setupDefaultPinNames(
      inputNames: ['D0', 'D1', 'D2', 'D3', 'CLK', 'LD', 'INC', 'CLR'],
      outputNames: ['Y0', 'Y1', 'Y2', 'Y3'],
    );
  }

  final List<bool> storedValues = [false, false, false, false];
  bool previousClock = false;

  @override
  Size get size => const Size(120, 130);

  @override
  String get tooltipTitle => 'Register';

  @override
  String get tooltipDescription =>
      'The register component stores 4-bit data and can increment the value by 1.';

  @override
  Map<String, String> get tooltipProperties => {
        'Inputs': 'D0, D1, D2, D3, CLK, LD, INC, CLR',
        'Outputs': 'Y0, Y1, Y2, Y3',
        'Operation':
            'When LD is high, the input data is loaded into the register. When INC is high, the value is incremented by 1. When CLR is high, the register is cleared.',
      };

  @override
  Widget build({
    required VoidCallback onInputToggle,
    required void Function(Pin pin) onPinTap,
    bool isSelected = false,
  }) {
    final componentBuilder = ComponentBuilder(
      id: id,
      child: const ComponentLabel(title: 'Register'),
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
    final dataInputs = inputPins.sublist(0, 4).map((pin) => pin.value).toList();
    final clock = inputPins[4].value;
    final load = inputPins[5].value;
    final increase = inputPins[6].value;
    final clear = inputPins[7].value;

    if (clear) {
      _reset();
    } else if (clock && !previousClock) {
      if (load) {
        for (var i = 0; i < storedValues.length; i++) {
          storedValues[i] = dataInputs[i];
        }
      } else if (increase) {
        _increment();
      }
    }

    for (var i = 0; i < outputPins.length; i++) {
      outputPins[i].value = storedValues[i];
    }

    previousClock = clock;
  }

  void _increment() {
    var value = 0;

    for (var i = 0; i < storedValues.length; i++) {
      if (storedValues[i]) {
        value |= 1 << i;
      }
    }

    value = (value + 1) % 16;

    for (var i = 0; i < storedValues.length; i++) {
      storedValues[i] = (value & (1 << i)) != 0;
    }
  }

  void _reset() {
    for (var i = 0; i < storedValues.length; i++) {
      storedValues[i] = false;
    }
  }
}
