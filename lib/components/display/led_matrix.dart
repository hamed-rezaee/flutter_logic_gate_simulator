import 'package:flutter/material.dart';
import 'package:flutter_logic_gate_simulator/components/components.dart';

class LedMatrix extends BaseLogicComponent
    with PinNamingMixin, ComponentInformationMixin {
  LedMatrix({required super.id, required super.position}) {
    for (var i = 0; i < 8; i++) {
      inputPins.add(Pin(index: i, component: this));
    }

    setupDefaultPinNames(
      inputNames: ['R1', 'R2', 'R3', 'R4', 'C1', 'C2', 'C3', 'C4'],
    );
  }

  @override
  Size get size => const Size(140, 125);

  @override
  String get title => 'LED Matrix';

  @override
  String get description =>
      'The LED matrix component displays a 4x4 grid of LEDs.';

  @override
  Map<String, String> get properties => {
        'Inputs': inputNames,
        'Outputs': outputNames,
        'Operation':
            'The LED at row R and column C is active if Rn and Cn are high.',
      };

  @override
  Widget build({
    required VoidCallback onInputToggle,
    required void Function(Pin pin) onPinTap,
    bool isSelected = false,
  }) =>
      ComponentBuilder(
        id: id,
        child: _buildContent(),
        inputPins: inputPins,
        outputPins: outputPins,
        information: information,
        isSelected: isSelected,
        position: position,
        size: size,
        onInputToggle: onInputToggle,
        onPinTap: onPinTap,
      );

  Widget _buildContent() => Column(
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
      );

  bool _isLedActive(int row, int col) =>
      inputPins[row].value && inputPins[col + 4].value;

  @override
  void calculateOutput() {}
}
