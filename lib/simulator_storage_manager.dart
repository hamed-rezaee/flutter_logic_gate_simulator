import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_logic_gate_simulator/components/components.dart';
import 'package:flutter_logic_gate_simulator/simulator_manager.dart';
import 'package:flutter_logic_gate_simulator/storage_service.dart';

class SimulatorStorageManager {
  SimulatorStorageManager(this.storageService);

  final BaseStorageService storageService;

  static const String fileExtension = 'lgs';
  static const String fileType = 'Logic Gate Simulator';
  static const String preferencesKey = 'simulator_serializer_key';

  static Future<SimulatorStorageManager> create() async =>
      SimulatorStorageManager(await DefaultStorageService.create());

  Future<bool> exportToFile(
    BuildContext context,
    SimulatorManager simulatorManager, {
    String? fileName,
  }) async {
    try {
      final data = serializeToJson(simulatorManager);
      final defaultFileName =
          'simulator_${DateTime.now().millisecondsSinceEpoch}.$fileExtension';

      final success = await storageService.saveFile(
        dialogTitle: 'Export Simulator State',
        fileName: fileName ?? defaultFileName,
        fileExtension: fileExtension,
        bytes: utf8.encode(data),
      );

      return success;
    } on Exception catch (e) {
      if (context.mounted) {
        _showErrorMessage(context, 'Failed to export simulator state: $e');
      }

      return false;
    }
  }

  Future<bool> importFromFile(
    BuildContext context,
    SimulatorManager simulatorManager,
  ) async {
    try {
      final fileContent = await storageService.pickFile(
        dialogTitle: 'Import Simulator State',
        fileExtension: fileExtension,
      );

      if (fileContent == null) {
        return false;
      }

      return deserializeFromJson(simulatorManager, fileContent);
    } on Exception catch (e) {
      if (context.mounted) {
        _showErrorMessage(context, 'Failed to import circuit: $e');
      }

      return false;
    }
  }

  Future<bool> saveToPreferences(SimulatorManager simulatorManager) async {
    try {
      return await storageService.saveToPreferences(
        preferencesKey,
        serializeToJson(simulatorManager),
      );
    } on Exception catch (_) {
      return false;
    }
  }

  Future<bool> loadFromPreferences(SimulatorManager simulatorManager) async {
    try {
      final json = await storageService.loadFromPreferences(preferencesKey);

      if (json == null) {
        return false;
      }

      return deserializeFromJson(simulatorManager, json);
    } on Exception catch (_) {
      return false;
    }
  }

  String serializeToJson(SimulatorManager simulatorManager) =>
      jsonEncode(_serialize(simulatorManager));

  bool deserializeFromJson(
    SimulatorManager simulatorManager,
    String jsonString,
  ) {
    try {
      return _deserialize(
        simulatorManager,
        jsonDecode(jsonString) as Map<String, dynamic>,
      );
    } on Exception catch (_) {
      return false;
    }
  }

  Map<String, dynamic> _serialize(SimulatorManager simulatorManager) {
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

  Map<String, dynamic> _serializeComponentProperties(
    BaseLogicComponent component,
  ) {
    final properties = <String, dynamic>{};

    if (component is Input) {
      properties['value'] = component.outputPins[0].value;
    } else if (component is Memory16x4) {
      properties['memoryContent'] = component.memoryContent;
    } else if (component is Memory32x8) {
      properties['memoryContent'] = component.memoryContent;
    }

    return properties;
  }

  bool _deserialize(
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

          final wire =
              Wire(startPin: startPin, endPin: endPin, segments: segments);

          simulatorManager.wires.add(wire);
        }
      }
    }

    simulatorManager.calculateAllOutputs();

    return true;
  }

  BaseLogicComponent? _createComponentFromData(Map<String, dynamic> data) {
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

  void _showErrorMessage(BuildContext context, String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }
}
