import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_logic_gate_simulator/components/components.dart';
import 'package:flutter_logic_gate_simulator/simulator_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SimulatorSerializer {
  static const String _simulatorSerializerKey = 'simulator_serializer_key';

  static Future<bool> save(SimulatorManager simulatorManager) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = _serialize(simulatorManager);

      return await prefs.setString(_simulatorSerializerKey, jsonEncode(data));
    } on Exception catch (_) {
      return false;
    }
  }

  static Future<bool> load(SimulatorManager simulatorManager) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString(_simulatorSerializerKey);

      if (json == null) {
        return false;
      }

      final data = jsonDecode(json) as Map<String, dynamic>;

      return _deserialize(simulatorManager, data);
    } on Exception catch (_) {
      return false;
    }
  }

  static String serializeToJson(SimulatorManager simulatorManager) {
    final data = _serialize(simulatorManager);

    return jsonEncode(data);
  }

  static bool deserializeFromJson(
    SimulatorManager simulatorManager,
    String jsonString,
  ) {
    try {
      final data = jsonDecode(jsonString) as Map<String, dynamic>;

      return _deserialize(simulatorManager, data);
    } on Exception catch (_) {
      return false;
    }
  }

  static Map<String, dynamic> _serialize(SimulatorManager simulatorManager) {
    final components = simulatorManager.components
        .map(
          (component) => {
            'id': component.id,
            'type': component.runtimeType.toString(),
            'position': {
              'dx': component.position.dx,
              'dy': component.position.dy,
            },
            'properties': _serializeComponentProperties(component),
          },
        )
        .toList();

    final wires = simulatorManager.wires
        .map(
          (wire) => {
            'startComponentId': wire.startPin.component.id,
            'startPinIndex': wire.startPin.index,
            'startPinIsOutput': wire.startPin.isOutput,
            'endComponentId': wire.endPin.component.id,
            'endPinIndex': wire.endPin.index,
            'endPinIsOutput': wire.endPin.isOutput,
          },
        )
        .toList();

    return {
      'components': components,
      'wires': wires,
      'version': '1.0',
      'metadata': {
        'created': DateTime.now().toIso8601String(),
        'appVersion': '1.0.0',
      },
    };
  }

  static bool _deserialize(
    SimulatorManager simulatorManager,
    Map<String, dynamic> data,
  ) {
    simulatorManager.clearAll();

    final idToComponent = <int, BaseLogicComponent>{};
    final components = data['components'] as List;

    for (final componentData in components) {
      final component =
          _createComponentFromData(componentData as Map<String, dynamic>);

      if (component != null) {
        simulatorManager.addComponent(component);
        idToComponent[component.id] = component;
      }
    }

    final wires = data['wires'] as List;

    for (final wireData in wires) {
      final startComponentId = wireData['startComponentId'] as int;
      final endComponentId = wireData['endComponentId'] as int;
      final startComponent = idToComponent[startComponentId];
      final endComponent = idToComponent[endComponentId];

      if (startComponent != null && endComponent != null) {
        final startPinIndex = wireData['startPinIndex'] as int;
        final endPinIndex = wireData['endPinIndex'] as int;

        Pin? startPin;

        if (wireData['startPinIsOutput'] as bool) {
          startPin = startComponent.outputPins
              .firstWhereOrNull((pin) => pin.index == startPinIndex);
        }

        Pin? endPin;

        if (!(wireData['endPinIsOutput'] as bool)) {
          endPin = endComponent.inputPins
              .firstWhereOrNull((pin) => pin.index == endPinIndex);
        }

        if (startPin != null && endPin != null) {
          final wire = WireModel(startPin: startPin, endPin: endPin);

          simulatorManager.wires.add(wire);
        }
      }
    }

    simulatorManager.calculateAllOutputs();

    return true;
  }

  static BaseLogicComponent? _createComponentFromData(
    Map<String, dynamic> data,
  ) {
    final id = data['id'] as int;
    final typeString = data['type'] as String;
    final positionData = data['position'] as Map<String, dynamic>;
    final position = Offset(
      positionData['dx'] as double,
      positionData['dy'] as double,
    );
    final properties = data['properties'] as Map<String, dynamic>? ?? {};

    switch (typeString) {
      case 'Input':
        return Input(id: id, position: position);
      case 'Output':
        return Output(id: id, position: position);
      case 'Clock':
        return Clock(id: id, position: position);
      case 'AndGate':
        return AndGate(id: id, position: position);
      case 'OrGate':
        return OrGate(id: id, position: position);
      case 'NotGate':
        return NotGate(id: id, position: position);
      case 'NandGate':
        return NandGate(id: id, position: position);
      case 'NorGate':
        return NorGate(id: id, position: position);
      case 'XorGate':
        return XorGate(id: id, position: position);
      case 'XnorGate':
        return XnorGate(id: id, position: position);
      case 'DFlipFlop':
        return DFlipFlop(id: id, position: position);
      case 'TFlipFlop':
        return TFlipFlop(id: id, position: position);
      case 'SRFlipFlop':
        return SRFlipFlop(id: id, position: position);
      case 'JKFlipFlop':
        return JKFlipFlop(id: id, position: position);
      case 'Adder':
        return Adder(id: id, position: position);
      case 'Counter':
        return Counter(id: id, position: position);
      case 'Encoder':
        return Encoder(id: id, position: position);
      case 'Decoder':
        return Decoder(id: id, position: position);
      case 'SevenSegment':
        return SevenSegment(id: id, position: position);
      case 'SevenSegmentDecoder':
        return SevenSegmentDecoder(id: id, position: position);
      case 'Oscilloscope':
        return Oscilloscope(id: id, position: position);
      case 'Multiplexer':
        return Multiplexer(id: id, position: position);
      case 'ShiftRegister':
        return ShiftRegister(id: id, position: position);
      case 'Comparator':
        return Comparator(id: id, position: position);
      case 'LedMatrix':
        return LedMatrix(id: id, position: position);
      case 'Memory':
        final memory = Memory(id: id, position: position);
        if (properties.containsKey('memoryContent')) {
          final memoryData = properties['memoryContent'] as List;
          for (var i = 0;
              i < memoryData.length && i < memory.memoryContent.length;
              i++) {
            final rowData = memoryData[i] as List;
            for (var j = 0;
                j < rowData.length && j < memory.memoryContent[i].length;
                j++) {
              memory.memoryContent[i][j] = rowData[j] as bool;
            }
          }
        }
        return memory;

      default:
        return null;
    }
  }

  static Map<String, dynamic> _serializeComponentProperties(
    BaseLogicComponent component,
  ) {
    final properties = <String, dynamic>{};

    if (component is Input) {
      properties['value'] = component.outputPins[0].value;
    } else if (component is Memory) {
      properties['memoryContent'] = component.memoryContent;
    }

    return properties;
  }
}
