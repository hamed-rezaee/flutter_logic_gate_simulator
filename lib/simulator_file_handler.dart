import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_logic_gate_simulator/simulator_manager.dart';
import 'package:flutter_logic_gate_simulator/simulator_serializer.dart';

class SimulatorFileHandler {
  static const String fileExtension = 'lgs';
  static const String fileType = 'Logic Gate Simulator';

  static Future<bool> exportToFile(
    BuildContext context,
    SimulatorManager simulatorManager, {
    String? fileName,
  }) async {
    try {
      final data = SimulatorSerializer.serializeToJson(simulatorManager);
      final defaultFileName =
          'simulator_${DateTime.now().millisecondsSinceEpoch}.$fileExtension';

      await FilePicker.platform.saveFile(
        dialogTitle: 'Export Simulator State',
        fileName: fileName ?? defaultFileName,
        type: FileType.custom,
        allowedExtensions: [fileExtension],
        bytes: utf8.encode(data),
      );
    } on Exception catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to export simulator state: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }

      return false;
    }

    return false;
  }

  static Future<bool> importFromFile(
    BuildContext context,
    SimulatorManager simulatorManager,
  ) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        dialogTitle: 'Import Simulator State',
        type: FileType.custom,
        allowedExtensions: [fileExtension],
      );

      if (result == null || result.files.isEmpty) {
        return false;
      }

      String fileContent;

      if (kIsWeb) {
        final bytes = result.files.first.bytes;

        if (bytes == null) return false;

        fileContent = utf8.decode(bytes);
      } else {
        final file = File(result.files.first.path!);

        fileContent = await file.readAsString();
      }

      return SimulatorSerializer.deserializeFromJson(
        simulatorManager,
        fileContent,
      );
    } on Exception catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to import circuit: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }

      return false;
    }
  }
}
