import 'package:flutter/material.dart';
import 'package:flutter_logic_gate_simulator/components/logic_components/base_logic_component.dart';
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
    body: Column(
      children: [
        Expanded(
          child: GestureDetector(
            onTapUp: (details) {
              if (_simulatorManager.isDrawingWire) {
                setState(_simulatorManager.cancelWireDrawing);
              }
            },
            child: DragTarget<BaseLogicComponent>(
              onWillAcceptWithDetails: (data) => true,
              onAcceptWithDetails: (data) {
                final newComponent =
                    data.data
                      ..position =
                          data.offset - const Offset(0, CustomAppBar.height);

                setState(() => _simulatorManager.addComponent(newComponent));
              },
              builder:
                  (context, candidateData, rejectedData) => Stack(
                    children: [
                      const BackgroundGrid(),
                      ...(_simulatorManager.wires.map(
                        (wire) => Wire(
                          startPosition: wire.startPin.position,
                          endPosition: wire.endPin.position,
                          isActive: wire.startPin.value,
                        ),
                      )),
                      if (_simulatorManager.isDrawingWire &&
                          _simulatorManager.wireStartPin != null &&
                          _simulatorManager.wireEndPosition != null)
                        Wire(
                          startPosition:
                              _simulatorManager.wireStartPin!.position,
                          endPosition: _simulatorManager.wireEndPosition!,
                          isActive: _simulatorManager.wireStartPin!.value,
                        ),
                      ...(_simulatorManager.components.map((component) {
                        return Positioned(
                          left: component.position.dx,
                          top: component.position.dy,
                          child: GestureDetector(
                            onDoubleTap:
                                () => setState(
                                  () => _simulatorManager.removeComponent(
                                    component,
                                  ),
                                ),
                            onPanUpdate: (details) {
                              setState(() {
                                component.position += details.delta;
                                _simulatorManager.calculateAllOutputs();
                              });
                            },
                            child: component.build(
                              onInputToggle:
                                  () => setState(
                                    _simulatorManager.calculateAllOutputs,
                                  ),
                              onPinTap: (pin) {
                                if (!_simulatorManager.isDrawingWire) {
                                  setState(() {
                                    _simulatorManager.isDrawingWire = true;
                                    _simulatorManager.wireStartPin = pin;
                                    _simulatorManager.wireEndPosition =
                                        pin.position;
                                  });
                                } else if (_simulatorManager.wireStartPin !=
                                    null) {
                                  if (_simulatorManager
                                          .wireStartPin!
                                          .isOutput &&
                                      !pin.isOutput) {
                                    if (_simulatorManager
                                            .wireStartPin!
                                            .component !=
                                        component) {
                                      setState(() {
                                        _simulatorManager.wires.add(
                                          WireModel(
                                            startPin:
                                                _simulatorManager.wireStartPin!,
                                            endPin: pin,
                                          ),
                                        );
                                        _simulatorManager
                                          ..cancelWireDrawing()
                                          ..calculateAllOutputs();
                                      });
                                    }
                                  } else if (!_simulatorManager
                                          .wireStartPin!
                                          .isOutput &&
                                      pin.isOutput) {
                                    if (_simulatorManager
                                            .wireStartPin!
                                            .component !=
                                        component) {
                                      setState(() {
                                        _simulatorManager.wires.add(
                                          WireModel(
                                            startPin: pin,
                                            endPin:
                                                _simulatorManager.wireStartPin!,
                                          ),
                                        );
                                        _simulatorManager
                                          ..cancelWireDrawing()
                                          ..calculateAllOutputs();
                                      });
                                    }
                                  } else {
                                    setState(
                                      _simulatorManager.cancelWireDrawing,
                                    );
                                  }
                                }
                              },
                            ),
                          ),
                        );
                      })),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Toolbar(simulatorManager: _simulatorManager),
                        ),
                      ),
                    ],
                  ),
            ),
          ),
        ),
      ],
    ),
  );
}
