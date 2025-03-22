import 'package:flutter/material.dart';
import 'package:flutter_logic_gate_simulator/components/components.dart';
import 'package:flutter_logic_gate_simulator/simulator_manager.dart';

class Toolbar extends StatefulWidget {
  const Toolbar({required this.simulatorManager, super.key});

  final SimulatorManager simulatorManager;

  @override
  State<Toolbar> createState() => _ToolbarState();
}

class _ToolbarState extends State<Toolbar> {
  String? _expandedGroup;

  static final Map<String, List<ComponentDefinition>> _componentGroups = {
    'I/O': [
      ComponentDefinition(
        widget: const Icon(Icons.apps_rounded, size: 32),
        label: 'INPUT',
        createComponent: (id) => Input(position: Offset.zero, id: id),
      ),
      ComponentDefinition(
        widget: const Icon(Icons.apps_rounded, size: 32),
        label: 'OUTPUT',
        createComponent: (id) => Output(position: Offset.zero, id: id),
      ),
      ComponentDefinition(
        widget: const Icon(Icons.apps_rounded, size: 32),
        label: 'CLOCK',
        createComponent: (id) => Clock(position: Offset.zero, id: id),
      ),
    ],
    'Basic Components': [
      ComponentDefinition(
        widget: const LogicGate(
          gateType: LogicGateType.not,
          gateColor: Colors.white,
        ),
        label: 'NOT',
        createComponent: (id) => NotGate(position: Offset.zero, id: id),
      ),
      ComponentDefinition(
        widget: const LogicGate(
          gateType: LogicGateType.and,
          gateColor: Colors.white,
        ),
        label: 'AND',
        createComponent: (id) => AndGate(position: Offset.zero, id: id),
      ),
      ComponentDefinition(
        widget: const LogicGate(
          gateType: LogicGateType.or,
          gateColor: Colors.white,
        ),
        label: 'OR',
        createComponent: (id) => OrGate(position: Offset.zero, id: id),
      ),
      ComponentDefinition(
        widget: const LogicGate(
          gateType: LogicGateType.xor,
          gateColor: Colors.white,
        ),
        label: 'XOR',
        createComponent: (id) => XorGate(position: Offset.zero, id: id),
      ),
      ComponentDefinition(
        widget: const LogicGate(
          gateType: LogicGateType.nand,
          gateColor: Colors.white,
        ),
        label: 'NAND',
        createComponent: (id) => NandGate(position: Offset.zero, id: id),
      ),
      ComponentDefinition(
        widget: const LogicGate(
          gateType: LogicGateType.nor,
          gateColor: Colors.white,
        ),
        label: 'NOR',
        createComponent: (id) => NorGate(position: Offset.zero, id: id),
      ),
      ComponentDefinition(
        widget: const LogicGate(
          gateType: LogicGateType.xnor,
          gateColor: Colors.white,
        ),
        label: 'XNOR',
        createComponent: (id) => XnorGate(position: Offset.zero, id: id),
      ),
    ],
    'Advanced Components': [
      ComponentDefinition(
        widget: const Icon(Icons.apps_rounded, size: 32),
        label: 'COUNTER',
        createComponent: (id) => Counter(position: Offset.zero, id: id),
      ),
      ComponentDefinition(
        widget: const Icon(Icons.apps_rounded, size: 32),
        label: 'ADDER',
        createComponent: (id) => Adder(position: Offset.zero, id: id),
      ),
      ComponentDefinition(
        widget: const Icon(Icons.apps_rounded, size: 32),
        label: 'MULTIPLEXER',
        createComponent: (id) => Multiplexer(position: Offset.zero, id: id),
      ),
      ComponentDefinition(
        widget: const Icon(Icons.apps_rounded, size: 32),
        label: 'COMPARATOR',
        createComponent: (id) => Comparator(position: Offset.zero, id: id),
      ),
      ComponentDefinition(
        widget: const Icon(Icons.apps_rounded, size: 32),
        label: 'ENCODER',
        createComponent: (id) => Encoder(position: Offset.zero, id: id),
      ),
      ComponentDefinition(
        widget: const Icon(Icons.apps_rounded, size: 32),
        label: 'DECODER',
        createComponent: (id) => Decoder(position: Offset.zero, id: id),
      ),
      ComponentDefinition(
        widget: const Icon(Icons.apps_rounded, size: 32),
        label: '7-SEG DECODER',
        createComponent: (id) =>
            SevenSegmentDecoder(position: Offset.zero, id: id),
      ),
      ComponentDefinition(
        widget: const Icon(Icons.apps_rounded, size: 32),
        label: 'ALU',
        createComponent: (id) => ALU(position: Offset.zero, id: id),
      ),
    ],
    'Memory': [
      ComponentDefinition(
        widget: const Icon(Icons.apps_rounded, size: 32),
        label: 'MEMORY 16x4',
        createComponent: (id) => Memory16x4(position: Offset.zero, id: id),
      ),
      ComponentDefinition(
        widget: const Icon(Icons.apps_rounded, size: 32),
        label: 'MEMORY 32x8',
        createComponent: (id) => Memory32x8(position: Offset.zero, id: id),
      ),
      ComponentDefinition(
        widget: const Icon(Icons.apps_rounded, size: 32),
        label: 'REGISTER',
        createComponent: (id) => Register(position: Offset.zero, id: id),
      ),
      ComponentDefinition(
        widget: const Icon(Icons.apps_rounded, size: 32),
        label: 'SHIFT REGISTER',
        createComponent: (id) => ShiftRegister(position: Offset.zero, id: id),
      ),
      ComponentDefinition(
        widget: const Icon(Icons.apps_rounded, size: 32),
        label: 'D FLIP-FLOP',
        createComponent: (id) => DFlipFlop(position: Offset.zero, id: id),
      ),
      ComponentDefinition(
        widget: const Icon(Icons.apps_rounded, size: 32),
        label: 'T FLIP-FLOP',
        createComponent: (id) => TFlipFlop(position: Offset.zero, id: id),
      ),
      ComponentDefinition(
        widget: const Icon(Icons.apps_rounded, size: 32),
        label: 'SR FLIP-FLOP',
        createComponent: (id) => SRFlipFlop(position: Offset.zero, id: id),
      ),
      ComponentDefinition(
        widget: const Icon(Icons.apps_rounded, size: 32),
        label: 'JK FLIP-FLOP',
        createComponent: (id) => JKFlipFlop(position: Offset.zero, id: id),
      ),
    ],
    'Display': [
      ComponentDefinition(
        widget: const Icon(Icons.apps_rounded, size: 32),
        label: 'SCOPE',
        createComponent: (id) => Oscilloscope(position: Offset.zero, id: id),
      ),
      ComponentDefinition(
        widget: const Icon(Icons.apps_rounded, size: 32),
        label: '7-SEGMENT',
        createComponent: (id) => SevenSegment(position: Offset.zero, id: id),
      ),
      ComponentDefinition(
        widget: const Icon(Icons.apps_rounded, size: 32),
        label: 'LED MATRIX',
        createComponent: (id) => LedMatrix(position: Offset.zero, id: id),
      ),
    ],
  };

  @override
  Widget build(BuildContext context) => TapRegion(
        onTapOutside: (_) => setState(() => _expandedGroup = null),
        child: SizedBox(
          height: 100,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ..._componentGroups.entries.map((entry) {
                final groupName = entry.key;
                final components = entry.value;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: GestureDetector(
                    onTap: () => _toggleGroup(groupName),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: AnimatedCrossFade(
                        duration: const Duration(milliseconds: 100),
                        alignment: Alignment.center,
                        crossFadeState: _expandedGroup == groupName
                            ? CrossFadeState.showSecond
                            : CrossFadeState.showFirst,
                        firstChild: _buildGroups(groupName),
                        secondChild: _buildSubgroup(components),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      );

  Widget _buildGroups(String groupName) => Padding(
        padding: const EdgeInsets.all(4),
        child: Text(
          groupName.toUpperCase(),
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      );

  Widget _buildSubgroup(List<ComponentDefinition> components) => Wrap(
        spacing: 8,
        children: components
            .map(
              (comp) => _buildComponentDraggable(
                comp.widget,
                comp.label,
                () => comp.createComponent(widget.simulatorManager.getNextId()),
              ),
            )
            .toList(),
      );

  Widget _buildComponentDraggable(
    Widget widget,
    String label,
    BaseLogicComponent Function() createComponent,
  ) =>
      Draggable<BaseLogicComponent>(
        data: createComponent(),
        feedback: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(4),
          ),
          child: SizedBox(width: 60, height: 40, child: widget),
        ),
        childWhenDragging: Column(
          children: [
            SizedBox(width: 60, height: 40, child: widget),
            Text(
              label,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        child: Column(
          children: [
            SizedBox(width: 60, height: 40, child: widget),
            Text(
              label,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );

  void _toggleGroup(String groupName) => setState(
        () => _expandedGroup == groupName
            ? _expandedGroup = null
            : _expandedGroup = groupName,
      );
}

class ComponentDefinition {
  const ComponentDefinition({
    required this.widget,
    required this.label,
    required this.createComponent,
  });

  final Widget widget;
  final String label;
  final BaseLogicComponent Function(int id) createComponent;
}
