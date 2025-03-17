import 'package:flutter/material.dart';
import 'package:flutter_logic_gate_simulator/components/pin.dart';

class ComponentBuilder extends StatelessWidget {
  const ComponentBuilder({
    required this.id,
    required this.child,
    required this.inputPins,
    required this.outputPins,
    required this.isSelected,
    required this.position,
    required this.size,
    required this.onInputToggle,
    required this.onPinTap,
    super.key,
  });

  final int id;
  final Widget child;
  final List<Pin> inputPins;
  final List<Pin> outputPins;
  final bool isSelected;
  final Offset position;
  final Size size;
  final VoidCallback onInputToggle;
  final void Function(Pin) onPinTap;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: size.width,
    height: size.height,
    child: Stack(
      children: [
        Center(
          child: Container(
            width: 60,
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: Colors.orange.withValues(alpha: isSelected ? 0.75 : 0),
                width: 2,
              ),
            ),
            child: Center(child: child),
          ),
        ),
        ...inputPins.map(
          (pin) => Positioned(
            left: 0,
            top: pin.position.dy - position.dy - 5,
            child: pin.build(onTap: onPinTap),
          ),
        ),
        ...outputPins.map(
          (pin) => Positioned(
            left: size.width - 10,
            top: pin.position.dy - position.dy - 5,
            child: pin.build(onTap: onPinTap),
          ),
        ),
      ],
    ),
  );
}
