import 'package:flutter/material.dart';
import 'package:flutter_logic_gate_simulator/components/components.dart';
import 'package:flutter_logic_gate_simulator/simulator_manager.dart';
import 'package:flutter_logic_gate_simulator/widgets/background_grid.dart';

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
                ..._buildWires(),
                if (widget.simulatorManager.isDrawingWire) _buildActiveWire(),
                ..._buildComponents(),
              ],
            ),
          ),
        ),
      );

  List<Widget> _buildWires() => widget.simulatorManager.wires
      .map(
        (wire) => Wire(
          key: ValueKey(
            'wire-${wire.startPin.component.id}-${wire.startPin.index}-${wire.endPin.component.id}-${wire.endPin.index}',
          ),
          startPosition: _canvasToScreenPosition(wire.startPosition),
          endPosition: _canvasToScreenPosition(wire.endPosition),
          isActive: wire.startPin.value,
          isSelected: wire == widget.simulatorManager.selectedWire,
          onTap: () => widget.simulatorManager.selectWire(wire),
        ),
      )
      .toList();

  Widget _buildActiveWire() {
    if (widget.simulatorManager.wireStartPin == null ||
        widget.simulatorManager.wireEndPosition == null) {
      return const SizedBox.shrink();
    }

    return Wire(
      startPosition: _canvasToScreenPosition(
        widget.simulatorManager.wireStartPin!.position,
      ),
      endPosition:
          _canvasToScreenPosition(widget.simulatorManager.wireEndPosition!),
      isActive: widget.simulatorManager.wireStartPin!.value,
      isSelected: false,
      isDashed: true,
    );
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
      _tryConnectWire(pin, component);
    }
  }

  void _tryConnectWire(Pin pin, BaseLogicComponent component) {
    final startPin = widget.simulatorManager.wireStartPin!;

    if (startPin.component == component) {
      widget.simulatorManager.cancelWireDrawing();

      return;
    }

    if (startPin.isOutput && !pin.isOutput) {
      final wire = WireModel(startPin: startPin, endPin: pin);

      widget.simulatorManager.wires.add(wire);
      widget.simulatorManager
        ..cancelWireDrawing()
        ..selectWire(wire);
    } else if (!startPin.isOutput && pin.isOutput) {
      final wire = WireModel(startPin: pin, endPin: startPin);

      widget.simulatorManager.wires.add(wire);
      widget.simulatorManager
        ..cancelWireDrawing()
        ..selectWire(wire);
    } else {
      widget.simulatorManager.cancelWireDrawing();
    }
  }
}
