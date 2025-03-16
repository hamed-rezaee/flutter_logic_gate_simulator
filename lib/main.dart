import 'package:flutter/material.dart';
import 'package:flutter_logic_gate_simulator/components/logic_components/base_logic_component.dart';
import 'package:flutter_logic_gate_simulator/components/pin.dart';
import 'package:flutter_logic_gate_simulator/components/wire.dart';
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
  Widget build(BuildContext context) => Scaffold(
    appBar: CustomAppBar(),
    body: Column(children: [Expanded(child: _buildSimulatorCanvas())]),
  );

  Widget _buildSimulatorCanvas() => MouseRegion(
    onHover: (event) {
      if (_simulatorManager.isDrawingWire) {
        setState(() => _simulatorManager.wireEndPosition = event.localPosition);
      }
    },
    child: GestureDetector(
      onTapUp: (details) {
        if (_simulatorManager.isDrawingWire) {
          setState(_simulatorManager.cancelWireDrawing);
        }
      },
      child: DragTarget<BaseLogicComponent>(
        onWillAcceptWithDetails: (data) => true,
        onAcceptWithDetails: _handleComponentDrop,
        builder:
            (context, candidateData, rejectedData) => Stack(
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
    final newComponent =
        details.data
          ..position = details.offset - const Offset(0, CustomAppBar.height);

    setState(() => _simulatorManager.addComponent(newComponent));
  }

  List<Widget> _buildWires() =>
      _simulatorManager.wires
          .map(
            (wire) => Wire(
              startPosition: wire.startPin.position,
              endPosition: wire.endPin.position,
              isActive: wire.startPin.value,
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
    );
  }

  List<Widget> _buildComponents() =>
      _simulatorManager.components
          .map(
            (component) => Positioned(
              left: component.position.dx,
              top: component.position.dy,
              child: GestureDetector(
                onDoubleTap:
                    () => setState(
                      () => _simulatorManager.removeComponent(component),
                    ),
                onPanUpdate: (details) {
                  setState(() {
                    component.position += details.delta;
                    _simulatorManager.calculateAllOutputs();
                  });
                },
                child: component.build(
                  onInputToggle:
                      () => setState(_simulatorManager.calculateAllOutputs),
                  onPinTap: (pin) => _handlePinTap(pin, component),
                ),
              ),
            ),
          )
          .toList();

  void _handlePinTap(Pin pin, BaseLogicComponent component) {
    if (!_simulatorManager.isDrawingWire) {
      setState(() => _simulatorManager.startWireDrawing(pin));
    } else if (_simulatorManager.wireStartPin != null) {
      _tryConnectWire(pin, component);
    }
  }

  void _tryConnectWire(Pin pin, BaseLogicComponent component) {
    final startPin = _simulatorManager.wireStartPin!;

    if (startPin.component == component) {
      setState(_simulatorManager.cancelWireDrawing);

      return;
    }

    setState(() {
      if (startPin.isOutput && !pin.isOutput) {
        _simulatorManager.wires.add(WireModel(startPin: startPin, endPin: pin));
        _simulatorManager
          ..cancelWireDrawing()
          ..calculateAllOutputs();
      } else if (!startPin.isOutput && pin.isOutput) {
        _simulatorManager.wires.add(WireModel(startPin: pin, endPin: startPin));
        _simulatorManager
          ..cancelWireDrawing()
          ..calculateAllOutputs();
      } else {
        _simulatorManager.cancelWireDrawing();
      }
    });
  }

  Widget _buildToolbar() => Align(
    alignment: Alignment.bottomCenter,
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Toolbar(simulatorManager: _simulatorManager),
    ),
  );
}
