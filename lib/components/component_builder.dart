import 'package:flutter/material.dart';
import 'package:flutter_logic_gate_simulator/components/components.dart';

class ComponentBuilder extends StatelessWidget {
  const ComponentBuilder({
    required this.id,
    required this.child,
    required this.inputPins,
    required this.outputPins,
    required this.information,
    required this.isSelected,
    required this.position,
    required this.size,
    required this.onInputToggle,
    required this.onPinTap,
    this.showPinLabels = true,
    super.key,
  });

  final int id;
  final Widget child;
  final List<Pin> inputPins;
  final List<Pin> outputPins;
  final String information;
  final bool isSelected;
  final Offset position;
  final Size size;
  final VoidCallback onInputToggle;
  final void Function(Pin) onPinTap;
  final bool showPinLabels;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: size.width,
        height: size.height,
        child: Stack(
          children: [
            Center(
              child: Container(
                width: size.width - 20,
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color:
                        Colors.orange.withValues(alpha: isSelected ? 0.75 : 0),
                    width: 2,
                  ),
                ),
                child: Stack(
                  children: [
                    Center(child: child),
                    Positioned(
                      top: 2,
                      right: 2,
                      child: ComponentInformation(information: information),
                    ),
                  ],
                ),
              ),
            ),
            ...inputPins.map((pin) => _buildPinWithLabel(pin, isInput: true)),
            ...outputPins.map((pin) => _buildPinWithLabel(pin, isInput: false)),
          ],
        ),
      );

  Widget _buildPinWithLabel(Pin pin, {required bool isInput}) {
    final pinWidget = pin.build(onTap: onPinTap);

    if (!showPinLabels || pin.name == null) {
      return Positioned(
        left: isInput ? 0 : null,
        right: isInput ? null : 0,
        top: pin.position.dy - position.dy - 5,
        child: pinWidget,
      );
    }

    final label = Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        pin.name!,
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.grey[400], fontSize: 8),
      ),
    );

    return Positioned(
      left: isInput ? 0 : null,
      right: isInput ? null : 0,
      top: pin.position.dy - position.dy - 5,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: isInput ? [pinWidget, label] : [label, pinWidget],
      ),
    );
  }
}
