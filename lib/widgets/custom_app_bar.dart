import 'package:flutter/material.dart';
import 'package:flutter_logic_gate_simulator/simulator_manager.dart';
import 'package:flutter_logic_gate_simulator/simulator_serializer.dart';

class CustomAppBar extends PreferredSize {
  CustomAppBar({
    this.actions,
    this.title = 'Logic Gate Simulator',
    this.simulatorManager,
    super.key,
  }) : super(
          preferredSize: const Size.fromHeight(height),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            height: height,
            child: Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (simulatorManager != null) ...[
                  SaveButton(simulatorManager: simulatorManager),
                  const SizedBox(width: 8),
                  LoadButton(simulatorManager: simulatorManager),
                  const SizedBox(width: 16),
                ],
                ...?actions,
              ],
            ),
          ),
        );

  final String title;
  final List<Widget>? actions;
  final SimulatorManager? simulatorManager;

  static const double height = 60;
}

class SaveButton extends StatelessWidget {
  const SaveButton({required this.simulatorManager, super.key});

  final SimulatorManager simulatorManager;

  @override
  Widget build(BuildContext context) => TextButton(
        child: const Icon(Icons.save, size: 32, color: Colors.white),
        onPressed: () async {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              content: const Text(
                'Are you sure you want to save the current simulator state?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child:
                      const Text('Save', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          );

          if (confirm != true) {
            return;
          }

          final success = await SimulatorSerializer.save(simulatorManager);

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  success
                      ? 'Simulator state saved successfully.'
                      : 'Failed to save simulator state.',
                ),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        },
      );
}

class LoadButton extends StatelessWidget {
  const LoadButton({required this.simulatorManager, super.key});

  final SimulatorManager simulatorManager;

  @override
  Widget build(BuildContext context) => TextButton(
        child: const Icon(Icons.folder_open, size: 32, color: Colors.white),
        onPressed: () async {
          if (simulatorManager.components.isNotEmpty) {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                content: const Text(
                  'Loading will replace your current simulator state, are you sure?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text(
                      'Load',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            );

            if (confirm != true) {
              return;
            }
          }

          final success = await SimulatorSerializer.load(simulatorManager);

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  success
                      ? 'Simulator state loaded successfully.'
                      : 'Failed to load simulator state.',
                ),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        },
      );
}
