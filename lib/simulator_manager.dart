import 'package:flutter/material.dart';
import 'package:flutter_logic_gate_simulator/components/components.dart';

class SimulatorManager {
  final List<BaseLogicComponent> components = [];
  final List<WireModel> wires = [];

  bool isDrawingWire = false;
  Pin? wireStartPin;
  Offset? wireEndPosition;

  bool isDeleteMode = false;

  BaseLogicComponent? selectedComponent;
  WireModel? selectedWire;

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

    selectComponent(component);
  }

  void removeComponent(BaseLogicComponent component) {
    wires.removeWhere(
      (wire) =>
          wire.startPin.component == component ||
          wire.endPin.component == component,
    );

    components.remove(component);
    component.dispose();

    if (selectedComponent == component) {
      selectedComponent = null;
    }
  }

  void selectComponent(BaseLogicComponent component) {
    selectedComponent = component;
    selectedWire = null;
  }

  void selectWire(WireModel wire) {
    selectedWire = wire;
    selectedComponent = null;
  }

  void clearSelection() {
    selectedComponent = null;
    selectedWire = null;
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

  void tryConnectWire(Pin pin, BaseLogicComponent component) {
    final startPin = wireStartPin!;

    if (startPin.component == component) {
      cancelWireDrawing();
      return;
    }

    if (startPin.isOutput && !pin.isOutput) {
      final wire = WireModel(startPin: startPin, endPin: pin)..autoRoute();

      wires.add(wire);
      cancelWireDrawing();
      selectWire(wire);

      return;
    } else if (!startPin.isOutput && pin.isOutput) {
      final wire = WireModel(startPin: pin, endPin: startPin)..autoRoute();

      wires.add(wire);
      cancelWireDrawing();
      selectWire(wire);

      return;
    } else {
      cancelWireDrawing();
    }
  }

  void startSegmentDrag(WireModel wire, int segmentIndex) {
    isDraggingWireSegment = true;
    draggingWire = wire;
    draggingSegmentIndex = segmentIndex;
  }

  void endSegmentDrag() {
    isDraggingWireSegment = false;
    draggingWire = null;
    draggingSegmentIndex = -1;
  }

  void updateDraggingSegment(Offset newPosition) {
    if (isDraggingWireSegment &&
        draggingWire != null &&
        draggingSegmentIndex >= 0) {
      draggingWire!.moveSegment(draggingSegmentIndex, newPosition);
    }
  }

  void addWireSegment(WireModel wire, int segmentIndex, Offset position) {
    wire.addSegment(segmentIndex, position);
  }

  bool isDraggingWireSegment = false;
  WireModel? draggingWire;
  int draggingSegmentIndex = -1;

  void removeWire(WireModel wire) {
    wires.remove(wire);

    if (selectedWire == wire) {
      selectedWire = null;
    }
  }

  void removeWiresForPin(Pin pin) =>
      wires.removeWhere((wire) => wire.startPin == pin || wire.endPin == pin);

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
      pin.value = false;
    }

    final componentWires =
        wires.where((wire) => wire.endPin.component == component);

    for (final wire in componentWires) {
      final startComponent = wire.startPin.component;

      _calculateOutput(startComponent);

      if (wire.startPin.value) {
        wire.endPin.value = true;
      }
    }

    component.calculateOutput();
  }

  void clearAll() {
    for (final component in components) {
      component.dispose();
    }

    wires.clear();
    components.clear();

    selectedComponent = null;
    selectedWire = null;

    cancelWireDrawing();
  }
}
