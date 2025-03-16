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
import 'package:flutter_logic_gate_simulator/components/pin.dart';
import 'package:flutter_logic_gate_simulator/components/wire.dart';
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

// Main simulator canvas
class SimulatorCanvas extends StatefulWidget {
  const SimulatorCanvas({super.key});

  @override
  State<SimulatorCanvas> createState() => _SimulatorCanvasState();
}

class _SimulatorCanvasState extends State<SimulatorCanvas> {
  // List of components on the canvas
  final List<BaseLogicComponent> _components = [];

  // List of wires connecting components
  final List<Wire> _wires = [];

  // Track if we're drawing a wire
  bool _isDrawingWire = false;
  Pin? _wireStartPin;
  Offset? _wireEndPosition;

  // Track if we're in delete mode
  bool _isDeleteMode = false;

  // Calculate all component outputs in the correct order
  void _calculateAllOutputs() {
    // Reset all visited flags
    for (final component in _components) {
      component.resetVisited();
    }

    // Start calculation from each component

    for (final component in _components) {
      _calculateOutput(component);
    }

    // Update the UI
    setState(() {});
  }

  // Recursive calculation of output for a component and its dependencies
  void _calculateOutput(BaseLogicComponent component) {
    // If already calculated, return
    if (component.visited) return;

    // Mark as visited
    component.visited = true;

    // Calculate inputs first
    for (final pin in component.inputPins) {
      // Find connected wires
      for (final wire in _wires) {
        if (wire.endPin == pin) {
          // Calculate output of the source component first
          _calculateOutput(wire.startPin.component);

          // Set input value based on connected output
          pin.value = wire.startPin.value;
        }
      }
    }

    // Now calculate this component's output
    component.calculateOutput();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: Column(
        children: [
          // Canvas for components and wires
          Expanded(
            child: GestureDetector(
              onTapUp: (details) {
                if (_isDrawingWire) {
                  setState(() {
                    _isDrawingWire = false;
                    _wireStartPin = null;
                    _wireEndPosition = null;
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
                    _components.add(newComponent);
                  });
                },
                builder: (context, candidateData, rejectedData) {
                  return Stack(
                    children: [
                      // Background
                      Container(
                        color: Colors.grey[900],
                        width: double.infinity,
                        height: double.infinity,
                        // Grid pattern
                        child: CustomPaint(painter: GridPainter()),
                      ),

                      // Draw all the permanent wires
                      ...(_wires.map(
                        (wire) => CustomPaint(
                          painter: WirePainter(
                            start: wire.startPosition,
                            end: wire.endPosition,
                            isActive: wire.startPin.value,
                          ),
                          size: Size.infinite,
                        ),
                      )),

                      // Draw the wire being created
                      if (_isDrawingWire &&
                          _wireStartPin != null &&
                          _wireEndPosition != null)
                        CustomPaint(
                          painter: WirePainter(
                            start: _wireStartPin!.position,
                            end: _wireEndPosition!,
                            isActive: _wireStartPin!.value,
                          ),
                          size: Size.infinite,
                        ),

                      // Draw all the components
                      ...(_components.map((component) {
                        return Positioned(
                          left: component.position.dx,
                          top: component.position.dy,
                          child: GestureDetector(
                            onPanUpdate: (details) {
                              setState(() {
                                component.position += details.delta;
                                _calculateAllOutputs();
                              });
                            },
                            child: component.build(
                              onInputToggle: () {
                                setState(_calculateAllOutputs);
                              },
                              onPinTap: (pin) {
                                if (_isDeleteMode) {
                                  // Delete connected wires in delete mode
                                  setState(() {
                                    _wires.removeWhere(
                                      (wire) =>
                                          wire.startPin == pin ||
                                          wire.endPin == pin,
                                    );
                                    _calculateAllOutputs();
                                  });
                                  return;
                                }

                                if (!_isDrawingWire) {
                                  // Start drawing a wire
                                  setState(() {
                                    _isDrawingWire = true;
                                    _wireStartPin = pin;
                                    _wireEndPosition = pin.position;
                                  });
                                } else if (_wireStartPin != null) {
                                  // Finish drawing a wire if types are compatible
                                  if (_wireStartPin!.isOutput &&
                                      !pin.isOutput) {
                                    if (_wireStartPin!.component != component) {
                                      setState(() {
                                        _wires.add(
                                          Wire(
                                            startPin: _wireStartPin!,
                                            endPin: pin,
                                          ),
                                        );
                                        _isDrawingWire = false;
                                        _wireStartPin = null;
                                        _wireEndPosition = null;
                                        _calculateAllOutputs();
                                      });
                                    }
                                  } else if (!_wireStartPin!.isOutput &&
                                      pin.isOutput) {
                                    if (_wireStartPin!.component != component) {
                                      setState(() {
                                        _wires.add(
                                          Wire(
                                            startPin: pin,
                                            endPin: _wireStartPin!,
                                          ),
                                        );
                                        _isDrawingWire = false;
                                        _wireStartPin = null;
                                        _wireEndPosition = null;
                                        _calculateAllOutputs();
                                      });
                                    }
                                  } else {
                                    // Cancel wire creation if types are incompatible
                                    setState(() {
                                      _isDrawingWire = false;
                                      _wireStartPin = null;
                                      _wireEndPosition = null;
                                    });
                                  }
                                }
                              },
                            ),
                          ),
                        );
                      })),

                      // Delete mode overlay for components
                      if (_isDeleteMode)
                        ...(_components.map((component) {
                          return Positioned(
                            left: component.position.dx,
                            top: component.position.dy,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  // Remove all connected wires first
                                  _wires.removeWhere(
                                    (wire) =>
                                        wire.startPin.component == component ||
                                        wire.endPin.component == component,
                                  );

                                  // Remove the component
                                  _components.remove(component);
                                  _calculateAllOutputs();
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
                  if (_isDrawingWire) {
                    setState(() {
                      _wireEndPosition = details.offset;
                    });
                  }
                },
              ),
            ),
          ),
          // Component palette
          Container(
            padding: const EdgeInsets.all(10),
            color: Colors.grey[800],
            height: 80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildComponentDraggable(
                  const LogicGateView(gateType: LogicGateType.and),
                  LogicGateType.and.name.toUpperCase(),
                  () => AndGate(position: Offset.zero, id: _getNextId()),
                ),
                _buildComponentDraggable(
                  const LogicGateView(gateType: LogicGateType.or),
                  LogicGateType.or.name.toUpperCase(),
                  () => OrGate(position: Offset.zero, id: _getNextId()),
                ),
                _buildComponentDraggable(
                  const LogicGateView(gateType: LogicGateType.not),
                  LogicGateType.not.name.toUpperCase(),
                  () => NotGate(position: Offset.zero, id: _getNextId()),
                ),
                _buildComponentDraggable(
                  const LogicGateView(gateType: LogicGateType.nand),
                  LogicGateType.nand.name.toUpperCase(),
                  () => NandGate(position: Offset.zero, id: _getNextId()),
                ),
                _buildComponentDraggable(
                  const LogicGateView(gateType: LogicGateType.nor),
                  LogicGateType.nor.name.toUpperCase(),
                  () => NorGate(position: Offset.zero, id: _getNextId()),
                ),
                _buildComponentDraggable(
                  const LogicGateView(gateType: LogicGateType.xand),
                  LogicGateType.xand.name.toUpperCase(),
                  () => XandGate(position: Offset.zero, id: _getNextId()),
                ),
                _buildComponentDraggable(
                  const LogicGateView(gateType: LogicGateType.xor),
                  LogicGateType.xor.name.toUpperCase(),
                  () => XorGate(position: Offset.zero, id: _getNextId()),
                ),
                _buildComponentDraggable(
                  const Icon(Icons.input),
                  'INPUT',
                  () => Input(position: Offset.zero, id: _getNextId()),
                ),
                _buildComponentDraggable(
                  const Icon(Icons.output),
                  'OUTPUT',
                  () => Output(position: Offset.zero, id: _getNextId()),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper to create draggable component for the palette
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

  // Generate a unique ID for new components
  int _getNextId() {
    var maxId = 0;
    for (final component in _components) {
      if (component.id > maxId) {
        maxId = component.id;
      }
    }
    return maxId + 1;
  }
}
