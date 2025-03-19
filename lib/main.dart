import 'package:flutter/material.dart';
import 'package:flutter_logic_gate_simulator/simulator_canvas.dart';
import 'package:flutter_logic_gate_simulator/simulator_manager.dart';
import 'package:flutter_logic_gate_simulator/widgets/custom_app_bar.dart';
import 'package:flutter_logic_gate_simulator/widgets/toolbar.dart';
import 'package:google_fonts/google_fonts.dart';

void main() => runApp(const LogicGateSimulator());

class LogicGateSimulator extends StatelessWidget {
  const LogicGateSimulator({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Logic Gate Simulator',
        theme: ThemeData(
          useMaterial3: false,
          primarySwatch: Colors.blueGrey,
          brightness: Brightness.dark,
          fontFamily: GoogleFonts.spaceMono().fontFamily,
        ),
        home: const Simulator(),
        debugShowCheckedModeBanner: false,
      );
}

class Simulator extends StatefulWidget {
  const Simulator({super.key});

  @override
  State<Simulator> createState() => _SimulatorState();
}

class _SimulatorState extends State<Simulator> {
  final SimulatorManager _simulatorManager = SimulatorManager();

  @override
  void initState() {
    super.initState();

    Stream<void>.periodic(const Duration(milliseconds: 16))
        .listen((_) => setState(_simulatorManager.calculateAllOutputs));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.black,
        appBar: CustomAppBar(simulatorManager: _simulatorManager),
        body: Stack(
          children: [
            SimulatorCanvas(
              appBarHeight: CustomAppBar.height,
              simulatorManager: _simulatorManager,
            ),
            _buildToolbar(),
          ],
        ),
      );

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
