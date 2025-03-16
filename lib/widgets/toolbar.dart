import 'package:flutter/material.dart';
import 'package:flutter_logic_gate_simulator/components/logic_components/logic_components.dart';
import 'package:flutter_logic_gate_simulator/simulator_manager.dart';
import 'package:flutter_logic_gate_simulator/widgets/gate_painter.dart';

class Toolbar extends StatelessWidget {
  const Toolbar({required this.simulatorManager, super.key});

  final SimulatorManager simulatorManager;

  @override
  Widget build(BuildContext context) => Container(
    height: 80,
    padding: const EdgeInsets.all(10),
    color: Colors.grey[800],
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildComponentDraggable(
          const Icon(Icons.input),
          'INPUT',
          () => Input(position: Offset.zero, id: simulatorManager.getNextId()),
        ),
        _buildComponentDraggable(
          const LogicGateView(gateType: LogicGateType.and),
          LogicGateType.and.name.toUpperCase(),
          () =>
              AndGate(position: Offset.zero, id: simulatorManager.getNextId()),
        ),
        _buildComponentDraggable(
          const LogicGateView(gateType: LogicGateType.or),
          LogicGateType.or.name.toUpperCase(),
          () => OrGate(position: Offset.zero, id: simulatorManager.getNextId()),
        ),
        _buildComponentDraggable(
          const LogicGateView(gateType: LogicGateType.not),
          LogicGateType.not.name.toUpperCase(),
          () =>
              NotGate(position: Offset.zero, id: simulatorManager.getNextId()),
        ),
        _buildComponentDraggable(
          const LogicGateView(gateType: LogicGateType.nand),
          LogicGateType.nand.name.toUpperCase(),
          () =>
              NandGate(position: Offset.zero, id: simulatorManager.getNextId()),
        ),
        _buildComponentDraggable(
          const LogicGateView(gateType: LogicGateType.nor),
          LogicGateType.nor.name.toUpperCase(),
          () =>
              NorGate(position: Offset.zero, id: simulatorManager.getNextId()),
        ),
        _buildComponentDraggable(
          const LogicGateView(gateType: LogicGateType.xand),
          LogicGateType.xand.name.toUpperCase(),
          () =>
              XandGate(position: Offset.zero, id: simulatorManager.getNextId()),
        ),
        _buildComponentDraggable(
          const LogicGateView(gateType: LogicGateType.xor),
          LogicGateType.xor.name.toUpperCase(),
          () =>
              XorGate(position: Offset.zero, id: simulatorManager.getNextId()),
        ),
        _buildComponentDraggable(
          const Icon(Icons.output),
          'OUTPUT',
          () => Output(position: Offset.zero, id: simulatorManager.getNextId()),
        ),
      ],
    ),
  );

  Widget _buildComponentDraggable(
    Widget widget,
    String label,
    BaseLogicComponent Function() createComponent,
  ) => Draggable<BaseLogicComponent>(
    data: createComponent(),
    feedback: Material(
      color: Colors.transparent,
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(8),
        ),
        child: SizedBox(width: 60, height: 40, child: widget),
      ),
    ),
    childWhenDragging: Opacity(
      opacity: 0.3,
      child: Column(
        children: [
          SizedBox(width: 60, height: 40, child: widget),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    ),
    child: Column(
      children: [
        SizedBox(width: 60, height: 40, child: widget),
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    ),
  );
}
