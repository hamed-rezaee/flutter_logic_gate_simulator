import 'dart:ui';

import 'package:flutter/material.dart';

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
  final List<LogicComponent> _components = [];

  // List of wires connecting components
  final List<Wire> _wires = [];

  // Track if we're drawing a wire
  bool _isDrawingWire = false;
  Pin? _wireStartPin;
  Offset? _wireEndPosition;

  // Track if we're in delete mode
  bool _isDeleteMode = false;

  @override
  void initState() {
    super.initState();

    // Add some initial components for testing
    _components.add(InputSwitch(position: const Offset(100, 100), id: 1));
    _components.add(InputSwitch(position: const Offset(100, 200), id: 2));
    _components.add(AndGate(position: const Offset(250, 150), id: 3));
    _components.add(OrGate(position: const Offset(400, 150), id: 4));
    _components.add(NotGate(position: const Offset(250, 300), id: 5));
    _components.add(OutputLamp(position: const Offset(550, 150), id: 6));

    // Calculate initial states
    _calculateAllOutputs();
  }

  // Calculate all component outputs in the correct order
  void _calculateAllOutputs() {
    // Reset all visited flags
    for (var component in _components) {
      component.resetVisited();
    }

    // Start calculation from each component
    for (var component in _components) {
      _calculateOutput(component);
    }

    // Update the UI
    setState(() {});
  }

  // Recursive calculation of output for a component and its dependencies
  void _calculateOutput(LogicComponent component) {
    // If already calculated, return
    if (component.visited) return;

    // Mark as visited
    component.visited = true;

    // Calculate inputs first
    for (var pin in component.inputPins) {
      // Find connected wires
      for (var wire in _wires) {
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
      appBar: AppBar(
        title: const Text('Logic Gate Simulator'),
        actions: [
          // Toggle delete mode
          IconButton(
            icon: Icon(
              _isDeleteMode ? Icons.delete_forever : Icons.delete_outline,
            ),
            onPressed: () {
              setState(() {
                _isDeleteMode = !_isDeleteMode;
              });
            },
          ),
          // Clear all
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: () {
              setState(() {
                _components.clear();
                _wires.clear();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Component palette
          Container(
            padding: const EdgeInsets.all(10),
            color: Colors.grey[800],
            height: 80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildComponentDraggable(
                  'Input Switch',
                  Icons.toggle_on,
                  () => InputSwitch(position: Offset.zero, id: _getNextId()),
                ),
                _buildComponentDraggable(
                  'AND Gate',
                  Icons.all_inclusive,
                  () => AndGate(position: Offset.zero, id: _getNextId()),
                ),
                _buildComponentDraggable(
                  'OR Gate',
                  Icons.change_history,
                  () => OrGate(position: Offset.zero, id: _getNextId()),
                ),
                _buildComponentDraggable(
                  'NOT Gate',
                  Icons.block,
                  () => NotGate(position: Offset.zero, id: _getNextId()),
                ),
                _buildComponentDraggable(
                  'NAND Gate',
                  Icons.shield,
                  () => NandGate(position: Offset.zero, id: _getNextId()),
                ),
                _buildComponentDraggable(
                  'NOR Gate',
                  Icons.lens_blur,
                  () => NorGate(position: Offset.zero, id: _getNextId()),
                ),
                _buildComponentDraggable(
                  'XOR Gate',
                  Icons.change_circle,
                  () => XorGate(position: Offset.zero, id: _getNextId()),
                ),
                _buildComponentDraggable(
                  'Output Lamp',
                  Icons.lightbulb,
                  () => OutputLamp(position: Offset.zero, id: _getNextId()),
                ),
              ],
            ),
          ),
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
              child: DragTarget<LogicComponent>(
                onWillAcceptWithDetails: (data) {
                  setState(() {
                    // Clone the component at the dropped position
                    LogicComponent newComponent = data.data;
                    newComponent.position = _wireEndPosition ?? Offset.zero;
                    _components.add(newComponent);
                    _calculateAllOutputs();
                  });

                  return true;
                },
                onAcceptWithDetails: (data) => data is LogicComponent,
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
                            isDashed: true,
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
                                setState(() {
                                  _calculateAllOutputs();
                                });
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
        ],
      ),
    );
  }

  // Helper to create draggable component for the palette
  Widget _buildComponentDraggable(
    String label,
    IconData icon,
    LogicComponent Function() createComponent,
  ) {
    return Draggable<LogicComponent>(
      data: createComponent(),
      feedback: Material(
        elevation: 4.0,
        child: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white),
              Text(label, style: const TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: Column(
          children: [
            Icon(icon),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
      child: Column(
        children: [
          Icon(icon),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  // Generate a unique ID for new components
  int _getNextId() {
    int maxId = 0;
    for (var component in _components) {
      if (component.id > maxId) {
        maxId = component.id;
      }
    }
    return maxId + 1;
  }
}

// Grid painter for the background
class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint =
        Paint()
          ..color = Colors.grey[800]!
          ..strokeWidth = 0.5;

    double gridSize = 20;

    for (double i = 0; i < size.width; i += gridSize) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }

    for (double i = 0; i < size.height; i += gridSize) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Wire painter
class WirePainter extends CustomPainter {
  final Offset start;
  final Offset end;
  final bool isActive;
  final bool isDashed;

  WirePainter({
    required this.start,
    required this.end,
    required this.isActive,
    this.isDashed = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint =
        Paint()
          ..color = isActive ? Colors.green : Colors.grey
          ..strokeWidth = 2.0
          ..style = PaintingStyle.stroke;

    // Calculate control points for the curve
    final double midX = (start.dx + end.dx) / 2;

    final Path path =
        Path()
          ..moveTo(start.dx, start.dy)
          ..cubicTo(midX, start.dy, midX, end.dy, end.dx, end.dy);

    if (isDashed) {
      // Draw dashed line
      final p = dashPath(
        path,
        dashArray: CircularIntervalList<double>([5.0, 5.0]),
      );
      canvas.drawPath(p, paint);
    } else {
      canvas.drawPath(path, paint);
    }
  }

  Path dashPath(
    Path source, {
    required CircularIntervalList<double> dashArray,
  }) {
    final Path dest = Path();
    for (final PathMetric metric in source.computeMetrics()) {
      double distance = 0;
      bool draw = true;
      while (distance < metric.length) {
        final double len = dashArray.next;
        if (draw) {
          dest.addPath(
            metric.extractPath(distance, distance + len),
            Offset.zero,
          );
        }
        distance += len;
        draw = !draw;
      }
    }
    return dest;
  }

  @override
  bool shouldRepaint(covariant WirePainter oldDelegate) =>
      oldDelegate.start != start ||
      oldDelegate.end != end ||
      oldDelegate.isActive != isActive ||
      oldDelegate.isDashed != isDashed;
}

// Circular interval list for dash pattern
class CircularIntervalList<T> {
  final List<T> _items;
  int _index = 0;

  CircularIntervalList(this._items);

  T get next {
    if (_items.isEmpty) {
      throw Exception('Cannot get next from empty list');
    }
    final T item = _items[_index];
    _index = (_index + 1) % _items.length;
    return item;
  }
}

// Base class for all logic components
abstract class LogicComponent {
  Offset position;
  final int id;
  final List<Pin> inputPins = [];
  final List<Pin> outputPins = [];
  bool visited = false;

  LogicComponent({required this.position, required this.id});

  // Size of the component
  Size get size;

  // Reset visited flag for calculation
  void resetVisited() {
    visited = false;
  }

  // Calculate output based on inputs
  void calculateOutput();

  // Build the component's widget
  Widget build({
    required VoidCallback onInputToggle,
    required Function(Pin) onPinTap,
  });

  // Create a new instance of the component
  LogicComponent clone();
}

// Pin class for input and output connections
class Pin {
  final LogicComponent component;
  final bool isOutput;
  final int index;
  bool value = false;

  Pin({required this.component, required this.isOutput, required this.index});

  // Position of the pin relative to the canvas
  Offset get position {
    if (isOutput) {
      return component.position +
          Offset(
            component.size.width,
            component.size.height /
                (component.outputPins.length + 1) *
                (index + 1),
          );
    } else {
      return component.position +
          Offset(
            0,
            component.size.height /
                (component.inputPins.length + 1) *
                (index + 1),
          );
    }
  }

  // Build the pin's widget
  Widget build({required Function(Pin) onTap}) {
    return GestureDetector(
      onTap: () => onTap(this),
      child: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: value ? Colors.green : Colors.grey,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 1),
        ),
      ),
    );
  }
}

// Wire class for connections between pins
class Wire {
  final Pin startPin;
  final Pin endPin;

  Wire({required this.startPin, required this.endPin});

  Offset get startPosition => startPin.position;
  Offset get endPosition => endPin.position;
}

// Input switch component
class InputSwitch extends LogicComponent {
  bool isOn = false;

  InputSwitch({required super.position, required super.id}) {
    // Create output pin
    outputPins.add(Pin(component: this, isOutput: true, index: 0));
  }

  @override
  Size get size => const Size(60, 40);

  @override
  void calculateOutput() {
    outputPins[0].value = isOn;
  }

  @override
  Widget build({
    required VoidCallback onInputToggle,
    required Function(Pin) onPinTap,
  }) {
    return SizedBox(
      width: size.width,
      height: size.height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Switch
          GestureDetector(
            onTap: () {
              isOn = !isOn;
              onInputToggle();
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey[700],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Center(
                child: Icon(
                  isOn ? Icons.toggle_on : Icons.toggle_off,
                  color: isOn ? Colors.green : Colors.grey,
                  size: 24,
                ),
              ),
            ),
          ),

          // Output pin
          ...outputPins.map((pin) => pin.build(onTap: onPinTap)),
        ],
      ),
    );
  }

  @override
  LogicComponent clone() {
    return InputSwitch(position: position, id: id);
  }
}

// Output lamp component
class OutputLamp extends LogicComponent {
  OutputLamp({required super.position, required super.id}) {
    // Create input pin
    inputPins.add(Pin(component: this, isOutput: false, index: 0));
  }

  @override
  Size get size => const Size(60, 40);

  @override
  void calculateOutput() {
    // Nothing to calculate for output lamp
  }

  @override
  Widget build({
    required VoidCallback onInputToggle,
    required Function(Pin) onPinTap,
  }) {
    return SizedBox(
      width: size.width,
      height: size.height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Input pin
          ...inputPins.map((pin) => pin.build(onTap: onPinTap)),

          // Lamp
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey[700],
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                Icons.lightbulb,
                color: inputPins[0].value ? Colors.yellow : Colors.grey[600],
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  LogicComponent clone() {
    return OutputLamp(position: position, id: id);
  }
}

// AND gate component
class AndGate extends LogicComponent {
  AndGate({required super.position, required super.id}) {
    // Create input pins
    inputPins.add(Pin(component: this, isOutput: false, index: 0));
    inputPins.add(Pin(component: this, isOutput: false, index: 1));

    // Create output pin
    outputPins.add(Pin(component: this, isOutput: true, index: 0));
  }

  @override
  Size get size => const Size(80, 60);

  @override
  void calculateOutput() {
    // AND gate logic
    outputPins[0].value = inputPins[0].value && inputPins[1].value;
  }

  @override
  Widget build({
    required VoidCallback onInputToggle,
    required Function(Pin) onPinTap,
  }) {
    return SizedBox(
      width: size.width,
      height: size.height,
      child: Stack(
        children: [
          // Gate body
          Center(
            child: Container(
              width: 60,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.blue[800],
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Center(
                child: Text(
                  'AND',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          // Input pins
          ...inputPins.map(
            (pin) => Positioned(
              left: 0,
              top: pin.position.dy - position.dy - 5,
              child: pin.build(onTap: onPinTap),
            ),
          ),

          // Output pins
          ...outputPins.map(
            (pin) => Positioned(
              left: size.width - 10,
              top: pin.position.dy - position.dy - 5,
              child: pin.build(onTap: onPinTap),
            ),
          ),
        ],
      ),
    );
  }

  @override
  LogicComponent clone() {
    return AndGate(position: position, id: id);
  }
}

// OR gate component
class OrGate extends LogicComponent {
  OrGate({required super.position, required super.id}) {
    // Create input pins
    inputPins.add(Pin(component: this, isOutput: false, index: 0));
    inputPins.add(Pin(component: this, isOutput: false, index: 1));

    // Create output pin
    outputPins.add(Pin(component: this, isOutput: true, index: 0));
  }

  @override
  Size get size => const Size(80, 60);

  @override
  void calculateOutput() {
    // OR gate logic
    outputPins[0].value = inputPins[0].value || inputPins[1].value;
  }

  @override
  Widget build({
    required VoidCallback onInputToggle,
    required Function(Pin) onPinTap,
  }) {
    return SizedBox(
      width: size.width,
      height: size.height,
      child: Stack(
        children: [
          // Gate body
          Center(
            child: Container(
              width: 60,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.orange[800],
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Center(
                child: Text(
                  'OR',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          // Input pins
          ...inputPins.map(
            (pin) => Positioned(
              left: 0,
              top: pin.position.dy - position.dy - 5,
              child: pin.build(onTap: onPinTap),
            ),
          ),

          // Output pins
          ...outputPins.map(
            (pin) => Positioned(
              left: size.width - 10,
              top: pin.position.dy - position.dy - 5,
              child: pin.build(onTap: onPinTap),
            ),
          ),
        ],
      ),
    );
  }

  @override
  LogicComponent clone() {
    return OrGate(position: position, id: id);
  }
}

// NOT gate component
class NotGate extends LogicComponent {
  NotGate({required super.position, required super.id}) {
    // Create input pin
    inputPins.add(Pin(component: this, isOutput: false, index: 0));

    // Create output pin
    outputPins.add(Pin(component: this, isOutput: true, index: 0));
  }

  @override
  Size get size => const Size(80, 40);

  @override
  void calculateOutput() {
    // NOT gate logic
    outputPins[0].value = !inputPins[0].value;
  }

  @override
  Widget build({
    required VoidCallback onInputToggle,
    required Function(Pin) onPinTap,
  }) {
    return SizedBox(
      width: size.width,
      height: size.height,
      child: Stack(
        children: [
          // Gate body
          Center(
            child: Container(
              width: 60,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.red[800],
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Center(
                child: Text(
                  'NOT',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          // Input pins
          ...inputPins.map(
            (pin) => Positioned(
              left: 0,
              top: pin.position.dy - position.dy - 5,
              child: pin.build(onTap: onPinTap),
            ),
          ),

          // Output pins
          ...outputPins.map(
            (pin) => Positioned(
              left: size.width - 10,
              top: pin.position.dy - position.dy - 5,
              child: pin.build(onTap: onPinTap),
            ),
          ),
        ],
      ),
    );
  }

  @override
  LogicComponent clone() {
    return NotGate(position: position, id: id);
  }
}

// NAND gate component
class NandGate extends LogicComponent {
  NandGate({required super.position, required super.id}) {
    // Create input pins
    inputPins.add(Pin(component: this, isOutput: false, index: 0));
    inputPins.add(Pin(component: this, isOutput: false, index: 1));

    // Create output pin
    outputPins.add(Pin(component: this, isOutput: true, index: 0));
  }

  @override
  Size get size => const Size(80, 60);

  @override
  void calculateOutput() {
    // NAND gate logic
    outputPins[0].value = !(inputPins[0].value && inputPins[1].value);
  }

  @override
  Widget build({
    required VoidCallback onInputToggle,
    required Function(Pin) onPinTap,
  }) {
    return SizedBox(
      width: size.width,
      height: size.height,
      child: Stack(
        children: [
          // Gate body
          Center(
            child: Container(
              width: 60,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.purple[800],
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Center(
                child: Text(
                  'NAND',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          // Input pins
          ...inputPins.map(
            (pin) => Positioned(
              left: 0,
              top: pin.position.dy - position.dy - 5,
              child: pin.build(onTap: onPinTap),
            ),
          ),

          // Output pins
          ...outputPins.map(
            (pin) => Positioned(
              left: size.width - 10,
              top: pin.position.dy - position.dy - 5,
              child: pin.build(onTap: onPinTap),
            ),
          ),
        ],
      ),
    );
  }

  @override
  LogicComponent clone() {
    return NandGate(position: position, id: id);
  }
}

// NOR gate component
class NorGate extends LogicComponent {
  NorGate({required super.position, required super.id}) {
    // Create input pins
    inputPins.add(Pin(component: this, isOutput: false, index: 0));
    inputPins.add(Pin(component: this, isOutput: false, index: 1));

    // Create output pin
    outputPins.add(Pin(component: this, isOutput: true, index: 0));
  }

  @override
  Size get size => const Size(80, 60);

  @override
  void calculateOutput() {
    // NOR gate logic
    outputPins[0].value = !(inputPins[0].value || inputPins[1].value);
  }

  @override
  Widget build({
    required VoidCallback onInputToggle,
    required Function(Pin) onPinTap,
  }) {
    return SizedBox(
      width: size.width,
      height: size.height,
      child: Stack(
        children: [
          // Gate body
          Center(
            child: Container(
              width: 60,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.teal[800],
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Center(
                child: Text(
                  'NOR',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          // Input pins
          ...inputPins.map(
            (pin) => Positioned(
              left: 0,
              top: pin.position.dy - position.dy - 5,
              child: pin.build(onTap: onPinTap),
            ),
          ),

          // Output pins
          ...outputPins.map(
            (pin) => Positioned(
              left: size.width - 10,
              top: pin.position.dy - position.dy - 5,
              child: pin.build(onTap: onPinTap),
            ),
          ),
        ],
      ),
    );
  }

  @override
  LogicComponent clone() {
    return NorGate(position: position, id: id);
  }
}

// XOR gate component
class XorGate extends LogicComponent {
  XorGate({required super.position, required super.id}) {
    // Create input pins
    inputPins.add(Pin(component: this, isOutput: false, index: 0));
    inputPins.add(Pin(component: this, isOutput: false, index: 1));

    // Create output pin
    outputPins.add(Pin(component: this, isOutput: true, index: 0));
  }

  @override
  Size get size => const Size(80, 60);

  @override
  void calculateOutput() {
    // XOR gate logic
    outputPins[0].value = inputPins[0].value != inputPins[1].value;
  }

  @override
  Widget build({
    required VoidCallback onInputToggle,
    required Function(Pin) onPinTap,
  }) {
    return SizedBox(
      width: size.width,
      height: size.height,
      child: Stack(
        children: [
          // Gate body
          Center(
            child: Container(
              width: 60,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.amber[800],
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Center(
                child: Text(
                  'XOR',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          // Input pins
          ...inputPins.map(
            (pin) => Positioned(
              left: 0,
              top: pin.position.dy - position.dy - 5,
              child: pin.build(onTap: onPinTap),
            ),
          ),

          // Output pins
          ...outputPins.map(
            (pin) => Positioned(
              left: size.width - 10,
              top: pin.position.dy - position.dy - 5,
              child: pin.build(onTap: onPinTap),
            ),
          ),
        ],
      ),
    );
  }

  @override
  LogicComponent clone() {
    return XorGate(position: position, id: id);
  }
}
