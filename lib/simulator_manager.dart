import 'package:flutter/material.dart';
import 'package:flutter_logic_gate_simulator/components/logic_components/base_logic_component.dart';
import 'package:flutter_logic_gate_simulator/components/pin.dart';
import 'package:flutter_logic_gate_simulator/components/wire.dart';

class SimulatorManager {
  final List<BaseLogicComponent> components = [];
  final List<WireModel> wires = [];

  bool isDrawingWire = false;
  Pin? wireStartPin;
  Offset? wireEndPosition;

  bool isDeleteMode = false;

  void calculateAllOutputs() {
    for (final component in components) {
      component.resetVisited();
    }

    for (final component in components) {
      _calculateOutput(component);
    }
  }

  void addComponent(BaseLogicComponent component) {
    components.add(component);
  }

  void removeComponent(BaseLogicComponent component) {
    wires.removeWhere(
      (wire) =>
          wire.startPin.component == component ||
          wire.endPin.component == component,
    );

    components.remove(component);
    component.dispose();

    calculateAllOutputs();
  }

  void startWireDrawing(Pin startPin) {
    isDrawingWire = true;
    wireStartPin = startPin;
    wireEndPosition = startPin.position;
  }

  void updateWireDrawing(Offset position) {
    if (isDrawingWire) {
      wireEndPosition = position;
    }
  }

  void cancelWireDrawing() {
    isDrawingWire = false;
    wireStartPin = null;
    wireEndPosition = null;
  }

  bool tryConnectWire(Pin endPin) {
    if (!isDrawingWire || wireStartPin == null) return false;

    if (wireStartPin!.component == endPin.component) {
      cancelWireDrawing();
      return false;
    }

    if (wireStartPin!.isOutput && !endPin.isOutput) {
      wires.add(WireModel(startPin: wireStartPin!, endPin: endPin));
      cancelWireDrawing();
      calculateAllOutputs();
      return true;
    } else if (!wireStartPin!.isOutput && endPin.isOutput) {
      wires.add(WireModel(startPin: endPin, endPin: wireStartPin!));
      cancelWireDrawing();
      calculateAllOutputs();
      return true;
    }

    cancelWireDrawing();
    return false;
  }

  void removeWiresForPin(Pin pin) {
    wires.removeWhere((wire) => wire.startPin == pin || wire.endPin == pin);
    calculateAllOutputs();
  }

  int getNextId() {
    var maxId = 0;
    for (final component in components) {
      if (component.id > maxId) {
        maxId = component.id;
      }
    }
    return maxId + 1;
  }

  void _calculateOutput(BaseLogicComponent component) {
    if (component.visited) return;

    component.visited = true;

    for (final pin in component.inputPins) {
      for (final wire in wires) {
        if (wire.endPin == pin) {
          _calculateOutput(wire.startPin.component);

          pin.value = wire.startPin.value;
        }
      }
    }

    component.calculateOutput();
  }
}
