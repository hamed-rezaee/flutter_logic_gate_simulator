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

  static String serializeToJson(SimulatorManager simulatorManager) =>
      jsonEncode(_serialize(simulatorManager));

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

  static BaseLogicComponent? _createComponentFromData(
    Map<String, dynamic> data,
  ) {
    final id = data['id'] as int;
    final type = data['type'] as String;
    final positionData = data['position'] as Map<String, dynamic>;
    final position = Offset(
      positionData['dx'] as double,
      positionData['dy'] as double,
    );
    final properties = data['properties'] as Map<String, dynamic>? ?? {};

    return ComponentFactory.createFromType(
      type: type,
      id: id,
      position: position,
      properties: properties,
    );
  }

  static Map<String, dynamic> _serialize(SimulatorManager simulatorManager) {
    final components = simulatorManager.components
        .map(
          (component) => {
            'id': component.id,
            'type': component.runtimeType.toString(),
            'position': {
              'dx': component.position.dx.roundToDouble(),
              'dy': component.position.dy.roundToDouble(),
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
            'segments': wire.segments
                .map(
                  (segment) => {
                    'dx': segment.dx.roundToDouble(),
                    'dy': segment.dy.roundToDouble(),
                  },
                )
                .toList(),
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

    final wires = data['wires'] as List<dynamic>;

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
          List<Offset>? segments;

          if ((wireData as Map).containsKey('segments')) {
            final segmentsList = wireData['segments'] as List;
            segments = segmentsList
                .map<Offset>(
                  (segData) =>
                      Offset(segData['dx'] as double, segData['dy'] as double),
                )
                .toList();
          }

          final wire = Wire(
            startPin: startPin,
            endPin: endPin,
            segments: segments,
          );

          simulatorManager.wires.add(wire);
        }
      }
    }

    simulatorManager.calculateAllOutputs();

    return true;
  }
}
