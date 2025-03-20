import 'package:flutter/material.dart';
import 'package:flutter_logic_gate_simulator/components/components.dart';
import 'package:flutter_logic_gate_simulator/simulator_manager.dart';
import 'package:flutter_logic_gate_simulator/widgets/background_grid.dart';
import 'package:flutter_logic_gate_simulator/wires_canvas.dart';

class SimulatorCanvas extends StatefulWidget {
  const SimulatorCanvas({
    required this.appBarHeight,
    required this.simulatorManager,
    super.key,
  });

  final double appBarHeight;
  final SimulatorManager simulatorManager;

  @override
  State<SimulatorCanvas> createState() => _SimulatorCanvasState();
}

class _SimulatorCanvasState extends State<SimulatorCanvas> {
  bool _isPanning = false;
  Offset _panOffset = Offset.zero;

  @override
  Widget build(BuildContext context) => MouseRegion(
        onHover: (event) {
          if (widget.simulatorManager.isDrawingWire) {
            widget.simulatorManager.wireEndPosition =
                _screenToCanvasPosition(event.localPosition);
          }
        },
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onPanStart: (_) => _isPanning = true,
          onPanUpdate: (details) => setState(() => _panOffset += details.delta),
          onPanEnd: (_) => _isPanning = false,
          onTapUp: (details) {
            if (_isPanning) return;

            widget.simulatorManager.isDrawingWire
                ? widget.simulatorManager.cancelWireDrawing()
                : widget.simulatorManager.clearSelection();
          },
          child: DragTarget<BaseLogicComponent>(
            onWillAcceptWithDetails: (data) => true,
            onAcceptWithDetails: _handleComponentDrop,
            builder: (context, candidateData, rejectedData) => Stack(
              children: [
                BackgroundGrid(panOffset: _panOffset),
                WiresCanvas(
                  simulatorManager: widget.simulatorManager,
                  panOffset: _panOffset,
                  onWireTap: _handleWireTap,
                ),
                ..._buildWireSegmentControls(),
                ..._buildComponents(),
              ],
            ),
          ),
        ),
      );

  List<Widget> _buildWireSegmentControls() {
    final wire = widget.simulatorManager.selectedWire;
    if (wire == null) return [];

    final segments =
        wire.segments.isEmpty ? wire.generateDefaultSegments() : wire.segments;

    final controlPoints = <Widget>[];

    for (var i = 0; i < segments.length; i++) {
      final screenPos = _canvasToScreenPosition(segments[i]);

      controlPoints.add(
        Positioned(
          left: screenPos.dx - 5,
          top: screenPos.dy - 5,
          child: GestureDetector(
            onPanStart: (_) =>
                widget.simulatorManager.startSegmentDrag(wire, i),
            onPanUpdate: (details) {
              final newPos = _screenToCanvasPosition(screenPos + details.delta);
              widget.simulatorManager.updateDraggingSegment(newPos);
            },
            onPanEnd: (_) => widget.simulatorManager.endSegmentDrag(),
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: Colors.blue,
                border: Border.all(color: Colors.white),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
        ),
      );
    }

    if (segments.isNotEmpty) {
      final allPoints = [wire.startPosition, ...segments, wire.endPosition];

      for (var i = 0; i < allPoints.length - 1; i++) {
        final start = _canvasToScreenPosition(allPoints[i]);
        final end = _canvasToScreenPosition(allPoints[i + 1]);
        final midpoint = Offset(
          (start.dx + end.dx) / 2,
          (start.dy + end.dy) / 2,
        );

        controlPoints.add(
          Positioned(
            left: midpoint.dx - 4,
            top: midpoint.dy - 4,
            child: GestureDetector(
              onTap: () {
                final canvasPos = _screenToCanvasPosition(midpoint);
                widget.simulatorManager.addWireSegment(wire, i, canvasPos);
              },
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.orange,
                  border: Border.all(color: Colors.white),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        );
      }
    }

    return controlPoints;
  }

  List<Widget> _buildComponents() => widget.simulatorManager.components
      .map(
        (component) => Positioned(
          left: component.position.dx + _panOffset.dx,
          top: component.position.dy + _panOffset.dy,
          child: GestureDetector(
            onTap: () => widget.simulatorManager.selectComponent(component),
            onPanUpdate: (details) {
              if (!_isPanning) {
                component.position += details.delta;
              }
            },
            child: component.build(
              onInputToggle: widget.simulatorManager.calculateAllOutputs,
              onPinTap: (pin) => _handlePinTap(pin, component),
              isSelected:
                  component == widget.simulatorManager.selectedComponent,
            ),
          ),
        ),
      )
      .toList();

  Offset _screenToCanvasPosition(Offset screenPosition) =>
      screenPosition - _panOffset;

  Offset _canvasToScreenPosition(Offset canvasPosition) =>
      canvasPosition + _panOffset;

  void _handleComponentDrop(DragTargetDetails<BaseLogicComponent> details) {
    final newComponent = details.data
      ..position = _screenToCanvasPosition(details.offset) -
          Offset(0, widget.appBarHeight);

    widget.simulatorManager.addComponent(newComponent);
  }

  void _handlePinTap(Pin pin, BaseLogicComponent component) {
    if (!widget.simulatorManager.isDrawingWire) {
      widget.simulatorManager.startWireDrawing(pin);
    } else if (widget.simulatorManager.wireStartPin != null) {
      widget.simulatorManager.tryConnectWire(pin, component);
    }
  }

  void _handleWireTap(WireModel? wire, Offset position) {
    if (wire != null) {
      widget.simulatorManager.selectWire(wire);
    } else if (!widget.simulatorManager.isDrawingWire) {
      widget.simulatorManager.clearSelection();
    }
  }
}
