import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_logic_gate_simulator/simulator_manager.dart';
import 'package:flutter_logic_gate_simulator/simulator_serializer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

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

      final exportFileName = fileName ?? defaultFileName;

      if (kIsWeb) {
        // final bytes = utf8.encode(data);
        // final blob = html.Blob([bytes]);
        // final url = html.Url.createObjectUrlFromBlob(blob);
        // final anchor = html.document.createElement('a') as html.AnchorElement
        //   ..href = url
        //   ..style.display = 'none'
        //   ..download = exportFileName;

        // html.document.body!.children.add(anchor);
        // anchor.click();

        // html.document.body!.children.remove(anchor);
        // html.Url.revokeObjectUrl(url);

        // return true;
      } else {
        final directory = await getTemporaryDirectory();
        final file = File('${directory.path}/$exportFileName');

        await file.writeAsString(data);

        await Share.shareXFiles(
          [XFile(file.path)],
          subject: 'Logic Gate Simulator',
        );

        return true;
      }
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
