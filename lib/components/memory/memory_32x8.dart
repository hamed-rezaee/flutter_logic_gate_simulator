import 'package:flutter/material.dart';
import 'package:flutter_logic_gate_simulator/components/components.dart';

class Memory32x8 extends BaseLogicComponent with PinNamingMixin, TooltipMixin {
  Memory32x8({required super.id, required super.position}) {
    for (var i = 0; i < 15; i++) {
      inputPins.add(Pin(index: i, component: this));
    }

    for (var i = 0; i < 8; i++) {
      outputPins.add(Pin(index: i, component: this, isOutput: true));
    }

    for (var i = 0; i < 32; i++) {
      memoryContent.add(List<bool>.filled(8, false));
    }

    setupDefaultPinNames(
      inputNames: [
        'A0',
        'A1',
        'A2',
        'A3',
        'A4',
        'D0',
        'D1',
        'D2',
        'D3',
        'D4',
        'D5',
        'D6',
        'D7',
        'WE',
        'RE',
      ],
      outputNames: ['Y0', 'Y1', 'Y2', 'Y3', 'Y4', 'Y5', 'Y6', 'Y7'],
    );
  }

  final List<List<bool>> memoryContent = [];

  int _activeAddress = 0;

  @override
  Size get size => const Size(190, 420);

  @override
  String get tooltipTitle => 'Memory';

  @override
  String get tooltipDescription =>
      'The memory component stores 8-bit data at 32 different addresses.';

  @override
  Map<String, String> get tooltipProperties => {
        'Inputs': inputNames,
        'Outputs': outputNames,
        'Operation':
            'WE: Write Enable, RE: Read Enable. When WE is high, the data at the address is set to the input data. When RE is high, the output is the data at the address.',
      };

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
        tooltip: tooltip,
        isSelected: isSelected,
        position: position,
        size: size,
        onInputToggle: onInputToggle,
        onPinTap: onPinTap,
      );

  Widget _buildMemoryDisplay(VoidCallback onInputToggle) {
    _activeAddress = (inputPins[4].value ? 16 : 0) +
        (inputPins[3].value ? 8 : 0) +
        (inputPins[2].value ? 4 : 0) +
        (inputPins[1].value ? 2 : 0) +
        (inputPins[0].value ? 1 : 0);

    return Container(
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(2),
      ),
      padding: const EdgeInsets.all(4),
      child: _buildMemoryMatrix(onInputToggle),
    );
  }

  Widget _buildMemoryMatrix(VoidCallback onInputToggle) => Table(
        defaultColumnWidth: const IntrinsicColumnWidth(),
        children: [
          TableRow(
            children: [
              const SizedBox.shrink(),
              ...List.generate(
                8,
                (bitIndex) => Container(
                  alignment: Alignment.center,
                  child: Text(
                    'D$bitIndex',
                    style: TextStyle(
                      fontSize: 8,
                      color: Colors.grey.shade400,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          ...List.generate(
            32,
            (address) => TableRow(
              decoration: BoxDecoration(
                color: address == _activeAddress
                    ? Colors.orange.withValues(alpha: 0.3)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(2),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    '0x${address.toRadixString(16).toUpperCase().padLeft(2, '0')}',
                    style: TextStyle(
                      fontSize: 8,
                      color: address == _activeAddress
                          ? Colors.white
                          : Colors.grey.shade400,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ...List.generate(8, (bitIndex) {
                  final isSet = memoryContent[address][bitIndex];

                  return GestureDetector(
                    onTap: () {
                      memoryContent[address][bitIndex] = !isSet;
                      onInputToggle();
                    },
                    child: Container(
                      width: 12,
                      height: 12,
                      padding: const EdgeInsets.symmetric(vertical: 2),
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
            ),
          ),
        ],
      );

  @override
  void calculateOutput() {
    final address = (inputPins[4].value ? 16 : 0) +
        (inputPins[3].value ? 8 : 0) +
        (inputPins[2].value ? 4 : 0) +
        (inputPins[1].value ? 2 : 0) +
        (inputPins[0].value ? 1 : 0);

    if (inputPins[13].value) {
      for (var i = 0; i < 8; i++) {
        memoryContent[address][i] = inputPins[i + 5].value;
      }
    }

    if (inputPins[14].value) {
      for (var i = 0; i < 8; i++) {
        outputPins[i].value = memoryContent[address][i];
      }
    } else {
      for (var i = 0; i < 8; i++) {
        outputPins[i].value = false;
      }
    }
  }
}
