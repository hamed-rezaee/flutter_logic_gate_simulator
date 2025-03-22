import 'package:flutter/material.dart';
import 'package:flutter_logic_gate_simulator/components/pin.dart';

abstract class BaseLogicComponent {
  BaseLogicComponent({required this.id, required this.position});

  final int id;
  final List<Pin> inputPins = [];
  final List<Pin> outputPins = [];

  Offset position;
  bool visited = false;

  Size get size => const Size(70, 40);

  Widget build({
    required VoidCallback onInputToggle,
    required void Function(Pin pin) onPinTap,
    bool isSelected = false,
  }) =>
      throw UnimplementedError();

  void calculateOutput() => throw UnimplementedError();

  void resetVisited() => visited = false;

  void dispose() {}
}

mixin PinNamingMixin on BaseLogicComponent {
  void setupDefaultPinNames({
    List<String> inputNames = const [],
    List<String> outputNames = const [],
  }) {
    assert(
      inputNames.length == inputPins.length,
      'Input names count must match input pins count',
    );

    assert(
      outputNames.length == outputPins.length,
      'Output names count must match output pins count',
    );

    for (var i = 0; i < inputPins.length; i++) {
      final pin = inputPins[i];
      final name = inputNames[i];

      inputPins[i] = Pin(
        index: pin.index,
        isOutput: pin.isOutput,
        component: pin.component,
        name: name,
      );
    }

    for (var i = 0; i < outputPins.length; i++) {
      final pin = outputPins[i];
      final name = outputNames[i];

      outputPins[i] = Pin(
        index: pin.index,
        isOutput: pin.isOutput,
        component: pin.component,
        name: name,
      );
    }
  }

  List<String?> get inputPinNames => inputPins.map((pin) => pin.name).toList();

  List<String?> get outputPinNames =>
      outputPins.map((pin) => pin.name).toList();

  String get inputNames {
    final names = inputPinNames.join(', ').trim();

    return names.isEmpty ? 'None' : names;
  }

  String get outputNames {
    final names = outputPinNames.join(', ').trim();

    return names.isEmpty ? 'None' : names;
  }
}

mixin ComponentInformationMixin on BaseLogicComponent {
  String get title => throw UnimplementedError();
  String get description => throw UnimplementedError();

  Map<String, String> get properties => {};

  String get information {
    final buffer = StringBuffer()
      ..writeln('$title:')
      ..writeln('\t$description');

    if (properties.isNotEmpty) {
      buffer.writeln('Description:');

      properties.forEach((key, value) => buffer.writeln('$key: \n$value'));
    }

    return buffer.toString().trim();
  }
}
