import 'package:flutter/material.dart';
import 'package:flutter_logic_gate_simulator/components/components.dart';
import 'package:flutter_logic_gate_simulator/simulator_manager.dart';
import 'package:flutter_logic_gate_simulator/widgets/background_grid.dart';
import 'package:flutter_logic_gate_simulator/widgets/custom_app_bar.dart';
import 'package:flutter_logic_gate_simulator/widgets/toolbar.dart';

void main() => runApp(const LogicGateSimulator());

class LogicGateSimulator extends StatelessWidget {
  const LogicGateSimulator({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Logic Gate Simulator',
        theme: ThemeData(
          primarySwatch: Colors.blueGrey,
          brightness: Brightness.dark,
          useMaterial3: false,
        ),
        home: const SimulatorCanvas(),
        debugShowCheckedModeBanner: false,
      );
}

class SimulatorCanvas extends StatefulWidget {
  const SimulatorCanvas({super.key});

  @override
  State<SimulatorCanvas> createState() => _SimulatorCanvasState();
}

class _SimulatorCanvasState extends State<SimulatorCanvas> {
  final SimulatorManager _simulatorManager = SimulatorManager();

  @override
  void initState() {
    super.initState();

    Stream<void>.periodic(const Duration(milliseconds: 10))
        .listen((_) => setState(_simulatorManager.calculateAllOutputs));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.black,
        appBar: CustomAppBar(simulatorManager: _simulatorManager),
        body: Column(children: [Expanded(child: _buildSimulatorCanvas())]),
      );

  Widget _buildSimulatorCanvas() => MouseRegion(
        onHover: (event) {
          if (_simulatorManager.isDrawingWire) {
            _simulatorManager.wireEndPosition = event.localPosition;
          }
        },
        child: GestureDetector(
          onTapUp: (details) {
            _simulatorManager.isDrawingWire
                ? _simulatorManager.cancelWireDrawing()
                : _simulatorManager.clearSelection();
          },
          child: DragTarget<BaseLogicComponent>(
            onWillAcceptWithDetails: (data) => true,
            onAcceptWithDetails: _handleComponentDrop,
            builder: (context, candidateData, rejectedData) => Stack(
              children: [
                const BackgroundGrid(),
                ..._buildWires(),
                if (_simulatorManager.isDrawingWire) _buildActiveWire(),
                ..._buildComponents(),
                _buildToolbar(),
              ],
            ),
          ),
        ),
      );

  void _handleComponentDrop(DragTargetDetails<BaseLogicComponent> details) {
    final newComponent = details.data
      ..position = details.offset - const Offset(0, CustomAppBar.height);

    _simulatorManager.addComponent(newComponent);
  }

  List<Widget> _buildWires() => _simulatorManager.wires
      .map(
        (wire) => Wire(
          key: ValueKey(
            'wire-${wire.startPin.component.id}-${wire.startPin.index}-${wire.endPin.component.id}-${wire.endPin.index}',
          ),
          startPosition: wire.startPosition,
          endPosition: wire.endPosition,
          isActive: wire.startPin.value,
          isSelected: wire == _simulatorManager.selectedWire,
          onTap: () => _simulatorManager.selectWire(wire),
        ),
      )
      .toList();

  Widget _buildActiveWire() {
    if (_simulatorManager.wireStartPin == null ||
        _simulatorManager.wireEndPosition == null) {
      return const SizedBox.shrink();
    }

    return Wire(
      startPosition: _simulatorManager.wireStartPin!.position,
      endPosition: _simulatorManager.wireEndPosition!,
      isActive: _simulatorManager.wireStartPin!.value,
      isSelected: false,
      isDashed: true,
    );
  }

  List<Widget> _buildComponents() => _simulatorManager.components
      .map(
        (component) => Positioned(
          left: component.position.dx,
          top: component.position.dy,
          child: GestureDetector(
            onTap: () => _simulatorManager.selectComponent(component),
            onDoubleTap: () {
              _simulatorManager.selectedComponent == component
                  ? _simulatorManager.removeComponent(component)
                  : _simulatorManager.selectComponent(component);
            },
            onPanUpdate: (details) => component.position += details.delta,
            child: component.build(
              onInputToggle: _simulatorManager.calculateAllOutputs,
              onPinTap: (pin) => _handlePinTap(pin, component),
              isSelected: component == _simulatorManager.selectedComponent,
            ),
          ),
        ),
      )
      .toList();

  void _handlePinTap(Pin pin, BaseLogicComponent component) {
    if (!_simulatorManager.isDrawingWire) {
      _simulatorManager.startWireDrawing(pin);
    } else if (_simulatorManager.wireStartPin != null) {
      _tryConnectWire(pin, component);
    }
  }

  void _tryConnectWire(Pin pin, BaseLogicComponent component) {
    final startPin = _simulatorManager.wireStartPin!;

    if (startPin.component == component) {
      _simulatorManager.cancelWireDrawing();

      return;
    }

    if (startPin.isOutput && !pin.isOutput) {
      final wire = WireModel(startPin: startPin, endPin: pin);

      _simulatorManager.wires.add(wire);
      _simulatorManager
        ..cancelWireDrawing()
        ..selectWire(wire);
    } else if (!startPin.isOutput && pin.isOutput) {
      final wire = WireModel(startPin: pin, endPin: startPin);

      _simulatorManager.wires.add(wire);
      _simulatorManager
        ..cancelWireDrawing()
        ..selectWire(wire);
    } else {
      _simulatorManager.cancelWireDrawing();
    }
  }

  Widget _buildToolbar() => Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedOpacity(
                duration: const Duration(milliseconds: 150),
                opacity: _simulatorManager.selectedComponent != null ||
                        _simulatorManager.selectedWire != null
                    ? 1
                    : 0,
                child: _buildDeleteButton(),
              ),
              Toolbar(simulatorManager: _simulatorManager),
            ],
          ),
        ),
      );

  Widget _buildDeleteButton() => InkWell(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: Colors.red.withValues(alpha: 0.5),
          ),
          child: const Text(
            'DELETE SELECTED ITEM',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
        onTap: () {
          if (_simulatorManager.selectedComponent != null) {
            _simulatorManager.removeComponent(
              _simulatorManager.selectedComponent!,
            );
          } else if (_simulatorManager.selectedWire != null) {
            _simulatorManager.removeWire(_simulatorManager.selectedWire!);
          }
        },
      );
}
