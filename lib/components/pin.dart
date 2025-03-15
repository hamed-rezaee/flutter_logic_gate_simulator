import 'package:flutter/material.dart';
import 'package:flutter_logic_gate_simulator/components/logic_components/base_logic_component.dart';

class Pin {
  Pin({required this.index, required this.isOutput, required this.component});

  final int index;
  final bool isOutput;
  final BaseLogicComponent component;

  bool value = false;

  Offset get position =>
      isOutput
          ? component.position +
              Offset(
                component.size.width,
                component.size.height /
                    (component.outputPins.length + 1) *
                    (index + 1),
              )
          : component.position +
              Offset(
                0,
                component.size.height /
                    (component.inputPins.length + 1) *
                    (index + 1),
              );

  Widget build({required void Function(Pin) onTap}) => GestureDetector(
    onTap: () => onTap(this),
    child: Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: value ? Colors.green : Colors.white,
        border: Border.all(color: Colors.grey[700]!, width: 3),
      ),
    ),
  );
}
