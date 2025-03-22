import 'package:flutter/material.dart';
import 'package:flutter_logic_gate_simulator/components/components.dart';

class ALU extends BaseLogicComponent
    with PinNamingMixin, ComponentInformationMixin {
  ALU({required super.id, required super.position}) {
    for (var i = 0; i < 21; i++) {
      inputPins.add(Pin(index: i, component: this));
    }

    for (var i = 0; i < 13; i++) {
      outputPins.add(Pin(index: i, component: this, isOutput: true));
    }

    setupDefaultPinNames(
      inputNames: [
        'A0',
        'A1',
        'A2',
        'A3',
        'A4',
        'A5',
        'A6',
        'A7',
        'B0',
        'B1',
        'B2',
        'B3',
        'B4',
        'B5',
        'B6',
        'B7',
        'OP0',
        'OP1',
        'OP2',
        'OP3',
        'Cin',
      ],
      outputNames: [
        'R0',
        'R1',
        'R2',
        'R3',
        'R4',
        'R5',
        'R6',
        'R7',
        'C',
        'Z',
        'N',
        'O',
        'P',
      ],
    );
  }

  @override
  Size get size => const Size(160, 377);

  @override
  String get title => 'Arithmetic Logic Unit (ALU)';

  @override
  String get description =>
      'The ALU performs arithmetic and logic operations on two 8-bit inputs. '
      'It outputs an 8-bit result and status flags.';

  @override
  Map<String, String> get properties => {
        'Inputs': inputNames,
        'Outputs': outputNames,
        'Operations': '''
          0: ADD (A+B+Cin)
          1: SUB (A-B)
          2: AND (A&B)
          3: OR (A|B)
          4: XOR (A^B)
          5: NOT (¬A)
          6: SHL (A<<1)
          7: SHR (A>>1)
          8: RLC (Rotate Left through Carry)
          9: RRC (Rotate Right through Carry)
          10: INC (A+1)
          11: DEC (A-1)
          12: NEG (-A)
          13: CPL (¬A, One's Complement)
          14: CMP (A-B, set flags only)
          15: PASS A
        ''',
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
        information: information,
        isSelected: isSelected,
        position: position,
        size: size,
        onInputToggle: onInputToggle,
        onPinTap: onPinTap,
      );

  @override
  void calculateOutput() {
    final aInputs = inputPins.sublist(0, 8).map((pin) => pin.value).toList();
    final bInputs = inputPins.sublist(8, 16).map((pin) => pin.value).toList();
    final operationSelect =
        inputPins.sublist(16, 20).map((pin) => pin.value).toList();
    final carryIn = inputPins[20].value;

    final opCode = _pinsToInt(operationSelect);
    final aValue = _pinsToInt(aInputs);
    final bValue = _pinsToInt(bInputs);

    var result = 0;
    var carry = false;
    var overflow = false;
    var parity = false;

    switch (opCode) {
      case 0:
        result = _add(aValue, bValue, carryIn);
        carry = _checkCarry(aValue, bValue, carryIn);
        overflow = _checkOverflow(aInputs, bInputs, result);
      case 1:
        result = _subtract(aValue, bValue);
        carry = _checkBorrow(aValue, bValue);
        overflow = _checkOverflow(aInputs, bInputs, result);
      case 2:
        result = aValue & bValue;
      case 3:
        result = aValue | bValue;
      case 4:
        result = aValue ^ bValue;
      case 5:
        result = (~aValue) & 0xFF;
      case 6:
        result = (aValue << 1) & 0xFF;
        carry = (aValue & 0x80) != 0;
      case 7:
        result = aValue >> 1;
        carry = (aValue & 0x01) != 0;
      case 8:
        result = ((aValue << 1) | (carryIn ? 1 : 0)) & 0xFF;
        carry = (aValue & 0x80) != 0;
      case 9:
        result = (aValue >> 1) | (carryIn ? 0x80 : 0);
        carry = (aValue & 0x01) != 0;
      case 10:
        result = _increment(aValue);
        carry = _checkCarry(aValue, 1, false);
        overflow = (aValue == 0x7F);
      case 11:
        result = _decrement(aValue);
        carry = _checkBorrow(aValue, 1);
        overflow = (aValue == 0x80);
      case 12:
        result = (-aValue) & 0xFF;
        carry = aValue != 0;
        overflow = (aValue == 0x80);
      case 13:
        result = (~aValue) & 0xFF;
      case 14:
        result = aValue;
        carry = _checkBorrow(aValue, bValue);
        overflow = _checkOverflow(aInputs, bInputs, aValue - bValue);
      case 15:
        result = aValue;
    }

    parity = _calculateParity(result);

    for (var i = 0; i < 8; i++) {
      outputPins[i].value = (result & (1 << i)) != 0;
    }

    outputPins[8].value = carry;
    outputPins[9].value = result == 0;
    outputPins[10].value = (result & 0x80) != 0;
    outputPins[11].value = overflow;
    outputPins[12].value = parity;
  }

  int _add(int a, int b, bool carryIn) => (a + b + (carryIn ? 1 : 0)) & 0xFF;

  int _subtract(int a, int b) => (a - b) & 0xFF;

  int _increment(int a) => (a + 1) & 0xFF;

  int _decrement(int a) => (a - 1) & 0xFF;

  bool _checkCarry(int a, int b, bool carryIn) =>
      (a + b + (carryIn ? 1 : 0)) > 0xFF;

  bool _checkBorrow(int a, int b) => a >= b;

  bool _checkOverflow(List<bool> aInputs, List<bool> bInputs, int result) {
    final aSign = aInputs[7];
    final bSign = bInputs[7];
    final rSign = (result & 0x80) != 0;

    return (aSign == bSign) && (rSign != aSign);
  }

  bool _calculateParity(int result) {
    var bitCount = 0;

    for (var i = 0; i < 8; i++) {
      if ((result & (1 << i)) != 0) {
        bitCount++;
      }
    }

    return (bitCount % 2) == 0;
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
