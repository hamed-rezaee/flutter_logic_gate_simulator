import 'package:flutter/material.dart';
import 'package:flutter_logic_gate_simulator/components/base_logic_component.dart';

class Pin {
  Pin({
    required this.index,
    required this.component,
    this.isOutput = false,
    this.name,
  });

  final int index;
  final bool isOutput;
  final BaseLogicComponent component;
  final String? name;

  bool value = false;

  Offset get position {
    final componentSize = component.size;
    final pinCount =
        isOutput ? component.outputPins.length : component.inputPins.length;
    final pinSpacing = componentSize.height / (pinCount + 1);
    final xPosition = isOutput ? componentSize.width : 0.0;
    final yPosition = pinSpacing * (index + 1);

    return component.position + Offset(xPosition, yPosition);
  }

  Widget build({required void Function(Pin) onTap}) => GestureDetector(
        onTap: () => onTap(this),
        child: Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: value ? Colors.green : Colors.grey[500]!,
            border: Border.all(color: Colors.grey[800]!, width: 3),
          ),
        ),
      );
}
