import 'package:flutter/material.dart';
import 'package:flutter_logic_gate_simulator/components/components.dart';

class LedMatrix extends BaseLogicComponent {
  LedMatrix({required super.id, required super.position}) {
    for (var i = 0; i < 4; i++) {
      inputPins.add(Pin(index: i, isOutput: false, component: this));
    }

    for (var i = 4; i < 8; i++) {
      inputPins.add(Pin(index: i, isOutput: false, component: this));
    }

    calculateOutput();
  }

  @override
  Size get size => const Size(120, 140);

  @override
  Widget build({
    required VoidCallback onInputToggle,
    required void Function(Pin pin) onPinTap,
    bool isSelected = false,
  }) =>
      ComponentBuilder(
        id: id,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 80,
              height: 80,
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 2,
                  mainAxisSpacing: 2,
                ),
                itemCount: 16,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final row = index ~/ 4;
                  final col = index % 4;
                  final isActive = _isLedActive(row, col);

                  return Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isActive ? Colors.green : Colors.grey[800],
                      border: Border.all(color: Colors.grey[700]!),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        position: position,
        size: size,
        isSelected: isSelected,
        inputPins: inputPins,
        outputPins: outputPins,
        onInputToggle: onInputToggle,
        onPinTap: onPinTap,
      );

  bool _isLedActive(int row, int col) =>
      inputPins[row].value && inputPins[col + 4].value;

  @override
  void calculateOutput() {}

  @override
  BaseLogicComponent clone() => LedMatrix(id: id, position: position);
}
