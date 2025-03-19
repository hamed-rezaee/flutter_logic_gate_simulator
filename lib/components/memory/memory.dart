import 'package:flutter/material.dart';
import 'package:flutter_logic_gate_simulator/components/components.dart';

class Memory extends BaseLogicComponent with PinNamingMixin {
  Memory({required super.id, required super.position}) {
    for (var i = 0; i < 9; i++) {
      inputPins.add(Pin(index: i, component: this));
    }

    for (var i = 0; i < 4; i++) {
      outputPins.add(Pin(index: i, component: this, isOutput: true));
    }

    for (var i = 0; i < 8; i++) {
      memoryContent.add(List<bool>.filled(4, false));
    }

    setupDefaultPinNames(
      inputNames: ['A0', 'A1', 'A2', 'D0', 'D1', 'D2', 'D3', 'WE', 'RE'],
      outputNames: ['Y0', 'Y1', 'Y2', 'Y3'],
    );
  }

  final List<List<bool>> memoryContent = [];

  int _activeAddress = 0;

  @override
  Size get size => const Size(170, 185);

  @override
  Widget build({
    required VoidCallback onInputToggle,
    required void Function(Pin pin) onPinTap,
    bool isSelected = false,
  }) =>
      ComponentBuilder(
        id: id,
        child: _buildMemoryDisplay(onInputToggle),
        inputPins: inputPins,
        outputPins: outputPins,
        isSelected: isSelected,
        position: position,
        size: size,
        onInputToggle: onInputToggle,
        onPinTap: onPinTap,
      );

  Widget _buildMemoryDisplay(VoidCallback onInputToggle) {
    _activeAddress = (inputPins[2].value ? 4 : 0) +
        (inputPins[1].value ? 2 : 0) +
        (inputPins[0].value ? 1 : 0);

    return Container(
      decoration: BoxDecoration(
        color: Colors.black54,
        border: Border.all(color: Colors.grey.shade700),
        borderRadius: BorderRadius.circular(2),
      ),
      padding: const EdgeInsets.all(6),
      child: _buildMemoryMatrix(onInputToggle),
    );
  }

  Widget _buildMemoryMatrix(VoidCallback onInputToggle) => Table(
        defaultColumnWidth: const IntrinsicColumnWidth(),
        children: [
          TableRow(
            children: [
              const SizedBox(width: 24),
              ...List.generate(4, (bitIndex) {
                return Container(
                  alignment: Alignment.center,
                  child: Text(
                    'D$bitIndex',
                    style: TextStyle(
                      fontSize: 8,
                      color: Colors.grey.shade400,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }),
            ],
          ),
          ...List.generate(8, (address) {
            return TableRow(
              decoration: BoxDecoration(
                color: address == _activeAddress
                    ? Colors.orange.withValues(alpha: 0.5)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(2),
              ),
              children: [
                Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    'M$address',
                    style: TextStyle(
                      fontSize: 8,
                      color: address == _activeAddress
                          ? Colors.white
                          : Colors.grey.shade400,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ...List.generate(4, (bitIndex) {
                  final isSet = memoryContent[address][bitIndex];
                  return GestureDetector(
                    onTap: () {
                      memoryContent[address][bitIndex] = !isSet;
                      onInputToggle();
                    },
                    child: Container(
                      width: 18,
                      height: 18,
                      padding: const EdgeInsets.all(4),
                      alignment: Alignment.center,
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSet ? Colors.green : Colors.grey.shade800,
                          shape: BoxShape.circle,
                          border: address == _activeAddress
                              ? Border.all(color: Colors.grey)
                              : null,
                        ),
                      ),
                    ),
                  );
                }),
              ],
            );
          }),
        ],
      );

  @override
  void calculateOutput() {
    final address = (inputPins[2].value ? 4 : 0) +
        (inputPins[1].value ? 2 : 0) +
        (inputPins[0].value ? 1 : 0);

    if (inputPins[7].value) {
      for (var i = 0; i < 4; i++) {
        memoryContent[address][i] = inputPins[i + 3].value;
      }
    }

    if (inputPins[8].value) {
      for (var i = 0; i < 4; i++) {
        outputPins[i].value = memoryContent[address][i];
      }
    } else {
      for (var i = 0; i < 4; i++) {
        outputPins[i].value = false;
      }
    }
  }
}
