import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class BaseStorageService {
  Future<String?> loadFromPreferences(String key);
  Future<bool> saveToPreferences(String key, String data);
  Future<String?> pickFile({
    required String dialogTitle,
    required String fileExtension,
  });
  Future<bool> saveFile({
    required String dialogTitle,
    required String fileName,
    required String fileExtension,
    required Uint8List bytes,
  });
}

class DefaultStorageService implements BaseStorageService {
  DefaultStorageService() {
    _initialize();
  }

  late SharedPreferences _preferences;

  Future<void> _initialize() async =>
      _preferences = await SharedPreferences.getInstance();

  @override
  Future<String?> loadFromPreferences(String key) async =>
      _preferences.getString(key);

  @override
  Future<bool> saveToPreferences(String key, String data) async =>
      _preferences.setString(key, data);

  @override
  Future<String?> pickFile({
    required String dialogTitle,
    required String fileExtension,
  }) async {
    final result = await FilePicker.platform.pickFiles(
      dialogTitle: dialogTitle,
      type: FileType.custom,
      allowedExtensions: [fileExtension],
    );

    if (result == null || result.files.isEmpty) {
      return null;
    }

    if (kIsWeb) {
      final bytes = result.files.first.bytes;

      if (bytes == null) return null;

      return utf8.decode(bytes);
    } else {
      final file = File(result.files.first.path!);

      return file.readAsString();
    }
  }

  @override
  Future<bool> saveFile({
    required String dialogTitle,
    required String fileName,
    required String fileExtension,
    required Uint8List bytes,
  }) async {
    final result = await FilePicker.platform.saveFile(
      dialogTitle: dialogTitle,
      fileName: fileName,
      type: FileType.custom,
      allowedExtensions: [fileExtension],
      bytes: bytes,
    );

    return result != null;
  }
}
