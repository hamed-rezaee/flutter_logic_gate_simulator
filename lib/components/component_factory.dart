import 'package:flutter/material.dart';
import 'package:flutter_logic_gate_simulator/components/components.dart';

class ComponentFactory {
  static BaseLogicComponent? createFromType({
    required String type,
    required int id,
    required Offset position,
    required Map<String, dynamic> properties,
  }) {
    switch (type) {
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
      case 'Memory16x4':
      case 'Memory32x8':
        return _createMemoryComponent(
          id: id,
          type: type,
          properties: properties,
          position: position,
        );
      case 'Register':
        return Register(id: id, position: position);
      case 'ALU':
        return ALU(id: id, position: position);

      default:
        return null;
    }
  }

  static BaseLogicComponent? _createMemoryComponent({
    required int id,
    required String type,
    required Map<String, dynamic> properties,
    required Offset position,
  }) {
    if (properties.containsKey('memoryContent')) {
      final memoryData = properties['memoryContent'] as List;

      if (type == 'Memory16x4') {
        final memory = Memory16x4(id: id, position: position);

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

        return memory;
      }

      if (type == 'Memory32x8') {
        final memory = Memory32x8(id: id, position: position);

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

        return memory;
      }
    }

    return null;
  }
}
