import 'package:flutter/material.dart';
import 'package:flutter_logic_gate_simulator/components/components.dart';

class ALU extends BaseLogicComponent with PinNamingMixin, TooltipMixin {
  ALU({required super.id, required super.position}) {
    for (var i = 0; i < 11; i++) {
      inputPins.add(Pin(index: i, component: this));
    }

    for (var i = 0; i < 8; i++) {
      outputPins.add(Pin(index: i, component: this, isOutput: true));
    }

    setupDefaultPinNames(
      inputNames: [
        'A0',
        'A1',
        'A2',
        'A3',
        'B0',
        'B1',
        'B2',
        'B3',
        'OP0',
        'OP1',
        'OP2',
      ],
      outputNames: ['R0', 'R1', 'R2', 'R3', 'Carry', 'Zero', 'Neg', 'Overflow'],
    );
  }

  @override
  Size get size => const Size(120, 175);

  @override
  String get tooltipTitle => 'Arithmetic Logic Unit (ALU)';

  @override
  String get tooltipDescription =>
      'The ALU performs arithmetic and logic operations on two 4-bit inputs. ';

  @override
  Map<String, String> get tooltipProperties => {
        'Inputs': inputNames,
        'Outputs': outputNames,
        'Operations':
            '0: ADD, 1: SUB, 2: AND, 3: OR, 4: XOR, 5: NOT, 6: SHL, 7: SHR',
      };

  @override
  Widget build({
    required VoidCallback onInputToggle,
    required void Function(Pin pin) onPinTap,
    bool isSelected = false,
  }) =>
      ComponentBuilder(
        id: id,
        child: const ComponentLabel(title: 'ALU'),
        inputPins: inputPins,
        outputPins: outputPins,
        tooltip: tooltip,
        isSelected: isSelected,
        position: position,
        size: size,
        onInputToggle: onInputToggle,
        onPinTap: onPinTap,
      );

  @override
  void calculateOutput() {
    final aInputs = inputPins.sublist(0, 4).map((pin) => pin.value).toList();
    final bInputs = inputPins.sublist(4, 8).map((pin) => pin.value).toList();
    final operationSelect =
        inputPins.sublist(8, 11).map((pin) => pin.value).toList();

    var opCode = 0;

    for (var i = 0; i < operationSelect.length; i++) {
      if (operationSelect[i]) {
        opCode |= 1 << i;
      }
    }

    final aValue = _pinsToInt(aInputs);
    final bValue = _pinsToInt(bInputs);

    var result = 0;
    var carry = false;
    var overflow = false;

    switch (opCode) {
      case 0:
        final sum = aValue + bValue;
        result = sum & 0xF;
        carry = sum > 0xF;

        final aSign = aInputs[3];
        final bSign = bInputs[3];
        final rSign = (result & 0x8) != 0;

        overflow = (aSign == bSign) && (rSign != aSign);
      case 1:
        final diff = aValue - bValue;
        result = diff & 0xF;
        carry = diff >= 0;

        final aSign = aInputs[3];
        final bSign = bInputs[3];
        final rSign = (result & 0x8) != 0;

        overflow = (aSign != bSign) && (rSign != aSign);
      case 2:
        result = aValue & bValue;
      case 3:
        result = aValue | bValue;
      case 4:
        result = aValue ^ bValue;
      case 5:
        result = (~aValue) & 0xF;
      case 6:
        result = (aValue << 1) & 0xF;
        carry = (aValue & 0x8) != 0;
      case 7:
        carry = (aValue & 0x1) != 0;
        result = aValue >> 1;
    }

    for (var i = 0; i < 4; i++) {
      outputPins[i].value = (result & (1 << i)) != 0;
    }

    outputPins[4].value = carry;
    outputPins[5].value = result == 0;
    outputPins[6].value = (result & 0x8) != 0;
    outputPins[7].value = overflow;
  }

  int _pinsToInt(List<bool> pins) {
    var result = 0;

    for (var i = 0; i < pins.length; i++) {
      if (pins[i]) {
        result |= 1 << i;
      }
    }

    return result;
  }
}
