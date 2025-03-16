import 'package:flutter/material.dart';
import 'package:flutter_logic_gate_simulator/components/logic_components/and_gate.dart';
import 'package:flutter_logic_gate_simulator/components/logic_components/base_logic_component.dart';
import 'package:flutter_logic_gate_simulator/components/logic_components/input.dart';
import 'package:flutter_logic_gate_simulator/components/logic_components/nand_gate.dart';
import 'package:flutter_logic_gate_simulator/components/logic_components/nor_gate.dart';
import 'package:flutter_logic_gate_simulator/components/logic_components/not_gate.dart';
import 'package:flutter_logic_gate_simulator/components/logic_components/or_gate.dart';
import 'package:flutter_logic_gate_simulator/components/logic_components/output.dart';
import 'package:flutter_logic_gate_simulator/components/logic_components/xand_gate.dart';
import 'package:flutter_logic_gate_simulator/components/logic_components/xor_gate.dart';
import 'package:flutter_logic_gate_simulator/components/wire.dart';
import 'package:flutter_logic_gate_simulator/simulator_manager.dart';
import 'package:flutter_logic_gate_simulator/widgets/custom_app_bar.dart';
import 'package:flutter_logic_gate_simulator/widgets/gate_painter.dart';
import 'package:flutter_logic_gate_simulator/widgets/grid_painter.dart';

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

  bool _isDeleteMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  setState(() {
                    _simulatorManager.components.add(newComponent);
                  });
                },
                builder: (context, candidateData, rejectedData) {
                  return Stack(
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
                            onPanUpdate: (details) {
                              setState(() {
                                component.position += details.delta;
                                _simulatorManager.calculateAllOutputs();
                              });
                            },
                            child: component.build(
                              onInputToggle: () {
                                setState(_simulatorManager.calculateAllOutputs);
                              },
                              onPinTap: (pin) {
                                if (_isDeleteMode) {
                                  setState(() {
                                    _simulatorManager.wires.removeWhere(
                                      (wire) =>
                                          wire.startPin == pin ||
                                          wire.endPin == pin,
                                    );
                                    _simulatorManager.calculateAllOutputs();
                                  });
                                  return;
                                }

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

                      if (_isDeleteMode)
                        ...(_simulatorManager.components.map((component) {
                          return Positioned(
                            left: component.position.dx,
                            top: component.position.dy,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _simulatorManager.wires.removeWhere(
                                    (wire) =>
                                        wire.startPin.component == component ||
                                        wire.endPin.component == component,
                                  );

                                  _simulatorManager.components.remove(
                                    component,
                                  );
                                  _simulatorManager.calculateAllOutputs();
                                });
                              },
                              child: Container(
                                width: component.size.width,
                                height: component.size.height,
                                decoration: BoxDecoration(
                                  color: Colors.red.withValues(alpha: 0.3),
                                  border: Border.all(
                                    color: Colors.red,
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          );
                        })),
                    ],
                  );
                },
                onMove: (details) {
                  if (_simulatorManager.isDrawingWire) {
                    setState(() {
                      _simulatorManager.wireEndPosition = details.offset;
                    });
                  }
                },
              ),
            ),
          ),

          Container(
            padding: const EdgeInsets.all(10),
            color: Colors.grey[800],
            height: 80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildComponentDraggable(
                  const Icon(Icons.input),
                  'INPUT',
                  () => Input(
                    position: Offset.zero,
                    id: _simulatorManager.getNextId(),
                  ),
                ),
                _buildComponentDraggable(
                  const Icon(Icons.output),
                  'OUTPUT',
                  () => Output(
                    position: Offset.zero,
                    id: _simulatorManager.getNextId(),
                  ),
                ),
                _buildComponentDraggable(
                  const LogicGateView(gateType: LogicGateType.and),
                  LogicGateType.and.name.toUpperCase(),
                  () => AndGate(
                    position: Offset.zero,
                    id: _simulatorManager.getNextId(),
                  ),
                ),
                _buildComponentDraggable(
                  const LogicGateView(gateType: LogicGateType.or),
                  LogicGateType.or.name.toUpperCase(),
                  () => OrGate(
                    position: Offset.zero,
                    id: _simulatorManager.getNextId(),
                  ),
                ),
                _buildComponentDraggable(
                  const LogicGateView(gateType: LogicGateType.not),
                  LogicGateType.not.name.toUpperCase(),
                  () => NotGate(
                    position: Offset.zero,
                    id: _simulatorManager.getNextId(),
                  ),
                ),
                _buildComponentDraggable(
                  const LogicGateView(gateType: LogicGateType.nand),
                  LogicGateType.nand.name.toUpperCase(),
                  () => NandGate(
                    position: Offset.zero,
                    id: _simulatorManager.getNextId(),
                  ),
                ),
                _buildComponentDraggable(
                  const LogicGateView(gateType: LogicGateType.nor),
                  LogicGateType.nor.name.toUpperCase(),
                  () => NorGate(
                    position: Offset.zero,
                    id: _simulatorManager.getNextId(),
                  ),
                ),
                _buildComponentDraggable(
                  const LogicGateView(gateType: LogicGateType.xand),
                  LogicGateType.xand.name.toUpperCase(),
                  () => XandGate(
                    position: Offset.zero,
                    id: _simulatorManager.getNextId(),
                  ),
                ),
                _buildComponentDraggable(
                  const LogicGateView(gateType: LogicGateType.xor),
                  LogicGateType.xor.name.toUpperCase(),
                  () => XorGate(
                    position: Offset.zero,
                    id: _simulatorManager.getNextId(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

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
