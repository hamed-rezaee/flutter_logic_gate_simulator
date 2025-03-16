import 'package:flutter/material.dart';
import 'package:flutter_logic_gate_simulator/components/logic_components/base_logic_component.dart';
import 'package:flutter_logic_gate_simulator/components/wire.dart';
import 'package:flutter_logic_gate_simulator/simulator_manager.dart';
import 'package:flutter_logic_gate_simulator/widgets/custom_app_bar.dart';
import 'package:flutter_logic_gate_simulator/widgets/grid_painter.dart';
import 'package:flutter_logic_gate_simulator/widgets/toolbar.dart';

void main() {
  runApp(const LogicGateSimulator());
}

class LogicGateSimulator extends StatelessWidget {
  const LogicGateSimulator({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Logic Gate Simulator',
      theme: ThemeData(primarySwatch: Colors.blue, brightness: Brightness.dark),
      home: const SimulatorCanvas(),
      debugShowCheckedModeBanner: false,
    );
  }
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
                setState(() {
                  _simulatorManager.isDrawingWire = false;
                  _simulatorManager.wireStartPin = null;
                  _simulatorManager.wireEndPosition = null;
                });
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
                      Container(
                        color: Colors.grey[900],
                        width: double.infinity,
                        height: double.infinity,

                        child: CustomPaint(painter: GridPainter()),
                      ),

                      ...(_simulatorManager.wires.map(
                        (wire) => CustomPaint(
                          painter: WirePainter(
                            start: wire.startPosition,
                            end: wire.endPosition,
                            isActive: wire.startPin.value,
                          ),
                          size: Size.infinite,
                        ),
                      )),

                      if (_simulatorManager.isDrawingWire &&
                          _simulatorManager.wireStartPin != null &&
                          _simulatorManager.wireEndPosition != null)
                        CustomPaint(
                          painter: WirePainter(
                            start: _simulatorManager.wireStartPin!.position,
                            end: _simulatorManager.wireEndPosition!,
                            isActive: _simulatorManager.wireStartPin!.value,
                          ),
                          size: Size.infinite,
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
                                          Wire(
                                            startPin:
                                                _simulatorManager.wireStartPin!,
                                            endPin: pin,
                                          ),
                                        );
                                        _simulatorManager.isDrawingWire = false;
                                        _simulatorManager.wireStartPin = null;
                                        _simulatorManager.wireEndPosition =
                                            null;
                                        _simulatorManager.calculateAllOutputs();
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
                                          Wire(
                                            startPin: pin,
                                            endPin:
                                                _simulatorManager.wireStartPin!,
                                          ),
                                        );
                                        _simulatorManager.isDrawingWire = false;
                                        _simulatorManager.wireStartPin = null;
                                        _simulatorManager.wireEndPosition =
                                            null;
                                        _simulatorManager.calculateAllOutputs();
                                      });
                                    }
                                  } else {
                                    setState(() {
                                      _simulatorManager.isDrawingWire = false;
                                      _simulatorManager.wireStartPin = null;
                                      _simulatorManager.wireEndPosition = null;
                                    });
                                  }
                                }
                              },
                            ),
                          ),
                        );
                      })),
                    ],
                  ),
            ),
          ),
        ),
        Toolbar(simulatorManager: _simulatorManager),
      ],
    ),
  );
}
