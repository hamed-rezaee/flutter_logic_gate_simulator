import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_logic_gate_simulator/simulator_canvas.dart';
import 'package:flutter_logic_gate_simulator/simulator_manager.dart';
import 'package:flutter_logic_gate_simulator/simulator_storage_manager.dart';
import 'package:flutter_logic_gate_simulator/storage_service.dart';
import 'package:flutter_logic_gate_simulator/widgets/custom_app_bar.dart';
import 'package:flutter_logic_gate_simulator/widgets/toolbar.dart';
import 'package:google_fonts/google_fonts.dart';

void main() => runApp(const LogicGateSimulator());

class LogicGateSimulator extends StatefulWidget {
  const LogicGateSimulator({super.key});

  @override
  State<LogicGateSimulator> createState() => _LogicGateSimulatorState();
}

class _LogicGateSimulatorState extends State<LogicGateSimulator> {
  final SimulatorManager simulatorManager = SimulatorManager();
  final SimulatorStorageManager storageManager =
      SimulatorStorageManager(DefaultStorageService());

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);

    Stream<void>.periodic(const Duration(milliseconds: 16))
        .listen((_) => setState(simulatorManager.calculateAllOutputs));
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Logic Gate Simulator',
        theme: ThemeData(
          useMaterial3: false,
          primarySwatch: Colors.blueGrey,
          brightness: Brightness.dark,
          fontFamily: GoogleFonts.spaceMono().fontFamily,
        ),
        home: SafeArea(
          child: Simulator(
            simulatorManager: simulatorManager,
            storageManager: storageManager,
          ),
        ),
      );
}

class Simulator extends StatelessWidget {
  const Simulator({
    required this.simulatorManager,
    required this.storageManager,
    super.key,
  });

  final SimulatorManager simulatorManager;
  final SimulatorStorageManager storageManager;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.black,
        appBar: CustomAppBar(
          simulatorManager: simulatorManager,
          storageManager: storageManager,
        ),
        body: Stack(
          children: [
            SimulatorCanvas(
              appBarHeight: CustomAppBar.height,
              simulatorManager: simulatorManager,
            ),
            _buildToolbar(),
          ],
        ),
      );

  Widget _buildToolbar() => Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedOpacity(
                duration: const Duration(milliseconds: 150),
                opacity: simulatorManager.selectedComponent != null ||
                        simulatorManager.selectedWire != null
                    ? 1
                    : 0,
                child: _buildDeleteButton(),
              ),
              Toolbar(simulatorManager: simulatorManager),
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
          if (simulatorManager.selectedComponent != null) {
            simulatorManager.removeComponent(
              simulatorManager.selectedComponent!,
            );
          } else if (simulatorManager.selectedWire != null) {
            simulatorManager.removeWire(simulatorManager.selectedWire!);
          }
        },
      );
}
