import 'package:flutter/material.dart';
import 'package:flutter_logic_gate_simulator/simulator_manager.dart';
import 'package:flutter_logic_gate_simulator/simulator_storage_manager.dart';

class CustomAppBar extends PreferredSize {
  CustomAppBar({
    required this.simulatorManager,
    required this.storageManager,
    this.title = 'Logic Gate Simulator',
    super.key,
  }) : super(
          preferredSize: const Size.fromHeight(height),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            height: height,
            child: Row(
              spacing: 8,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                ...[
                  SaveAction(
                    simulatorManager: simulatorManager,
                    storageManager: storageManager,
                  ),
                  LoadAction(
                    simulatorManager: simulatorManager,
                    storageManager: storageManager,
                  ),
                  ExportAction(
                    simulatorManager: simulatorManager,
                    storageManager: storageManager,
                  ),
                  ImportAction(
                    simulatorManager: simulatorManager,
                    storageManager: storageManager,
                  ),
                  OptimizeWireAction(simulatorManager: simulatorManager),
                  ShowMinimapAction(simulatorManager: simulatorManager),
                  ClearAction(simulatorManager: simulatorManager),
                ],
              ],
            ),
          ),
        );

  final String title;
  final SimulatorManager simulatorManager;
  final SimulatorStorageManager storageManager;

  static const double height = 60;
}

class SaveAction extends StatelessWidget {
  const SaveAction({
    required this.simulatorManager,
    required this.storageManager,
    super.key,
  });

  final SimulatorManager simulatorManager;
  final SimulatorStorageManager storageManager;

  @override
  Widget build(BuildContext context) => Tooltip(
        message: 'Save simulation',
        child: TextButton(
          child: const Icon(Icons.save, size: 24, color: Colors.white),
          onPressed: () async {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                content: const Text(
                  'Are you sure you want to save the current simulator state?',
                ),
                actions: [
                  _buildActionButton(
                    context: context,
                    onPressed: () => Navigator.of(context).pop(true),
                    text: 'Save',
                  ),
                  _buildActionButton(
                    context: context,
                    onPressed: () => Navigator.of(context).pop(false),
                    text: 'Cancel',
                  ),
                ],
              ),
            );

            if (confirm != true) {
              return;
            }

            final success =
                await storageManager.saveToPreferences(simulatorManager);

            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    success
                        ? 'Simulator state saved successfully.'
                        : 'Failed to save simulator state.',
                  ),
                ),
              );
            }
          },
        ),
      );
}

class LoadAction extends StatelessWidget {
  const LoadAction({
    required this.simulatorManager,
    required this.storageManager,
    super.key,
  });

  final SimulatorManager simulatorManager;
  final SimulatorStorageManager storageManager;

  @override
  Widget build(BuildContext context) => Tooltip(
        message: 'Load saved simulation',
        child: TextButton(
          child: const Icon(Icons.folder_open, size: 24, color: Colors.white),
          onPressed: () async {
            if (simulatorManager.components.isNotEmpty) {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  content: const Text(
                    'Loading will replace your current simulator state, are you sure?',
                  ),
                  actions: [
                    _buildActionButton(
                      context: context,
                      onPressed: () => Navigator.of(context).pop(true),
                      text: 'Load',
                    ),
                    _buildActionButton(
                      context: context,
                      onPressed: () => Navigator.of(context).pop(false),
                      text: 'Cancel',
                    ),
                  ],
                ),
              );

              if (confirm != true) {
                return;
              }
            }

            final success =
                await storageManager.loadFromPreferences(simulatorManager);

            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    success
                        ? 'Simulator state loaded successfully.'
                        : 'Failed to load simulator state.',
                  ),
                ),
              );
            }
          },
        ),
      );
}

class ExportAction extends StatelessWidget {
  const ExportAction({
    required this.simulatorManager,
    required this.storageManager,
    super.key,
  });

  final SimulatorManager simulatorManager;
  final SimulatorStorageManager storageManager;

  @override
  Widget build(BuildContext context) => Tooltip(
        message: 'Export simulation to file',
        child: TextButton(
          child: const Icon(Icons.file_upload, size: 24, color: Colors.white),
          onPressed: () async {
            if (simulatorManager.components.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content:
                      Text('Nothing to export. Create a simulation first.'),
                ),
              );
              return;
            }

            final success = await storageManager.exportToFile(
              context,
              simulatorManager,
              fileName:
                  'simulator_state_${DateTime.now().millisecondsSinceEpoch}.lgs',
            );

            if (context.mounted && success) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Simulator state exported successfully.'),
                ),
              );
            }
          },
        ),
      );
}

class ImportAction extends StatelessWidget {
  const ImportAction({
    required this.simulatorManager,
    required this.storageManager,
    super.key,
  });

  final SimulatorManager simulatorManager;
  final SimulatorStorageManager storageManager;

  @override
  Widget build(BuildContext context) => Tooltip(
        message: 'Import simulation from file',
        child: TextButton(
          child: const Icon(Icons.file_download, size: 24, color: Colors.white),
          onPressed: () async {
            if (simulatorManager.components.isNotEmpty) {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  content: const Text(
                    'Importing will replace your current simulator state, are you sure?',
                  ),
                  actions: [
                    _buildActionButton(
                      context: context,
                      onPressed: () => Navigator.of(context).pop(true),
                      text: 'Import',
                    ),
                    _buildActionButton(
                      context: context,
                      onPressed: () => Navigator.of(context).pop(false),
                      text: 'Cancel',
                    ),
                  ],
                ),
              );

              if (confirm != true) {
                return;
              }
            }

            if (!context.mounted) return;

            final success =
                await storageManager.importFromFile(context, simulatorManager);

            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    success
                        ? 'Simulator state imported successfully.'
                        : 'Failed to import simulator state.',
                  ),
                ),
              );
            }
          },
        ),
      );
}

class OptimizeWireAction extends StatelessWidget {
  const OptimizeWireAction({required this.simulatorManager, super.key});

  final SimulatorManager simulatorManager;

  @override
  Widget build(BuildContext context) => Tooltip(
        message: 'Optimize wire paths',
        child: TextButton(
          child: const Icon(
            Icons.account_tree_sharp,
            size: 24,
            color: Colors.white,
          ),
          onPressed: () {
            for (final wire in simulatorManager.wires) {
              wire.optimize();
            }

            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Wire paths optimized successfully.'),
                ),
              );
            }
          },
        ),
      );
}

class ShowMinimapAction extends StatelessWidget {
  const ShowMinimapAction({required this.simulatorManager, super.key});

  final SimulatorManager simulatorManager;

  @override
  Widget build(BuildContext context) => Tooltip(
        message: 'Toggle minimap',
        child: TextButton(
          child: const Icon(Icons.map_outlined, size: 24, color: Colors.white),
          onPressed: () =>
              simulatorManager.showMinimap = !simulatorManager.showMinimap,
        ),
      );
}

class ClearAction extends StatelessWidget {
  const ClearAction({required this.simulatorManager, super.key});

  final SimulatorManager simulatorManager;

  @override
  Widget build(BuildContext context) => Tooltip(
        message: 'Clear simulation',
        child: TextButton(
          child:
              const Icon(Icons.delete_outline, size: 24, color: Colors.white),
          onPressed: () async {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                content: const Text(
                  'Are you sure you want to clear the current simulator state?',
                ),
                actions: [
                  _buildActionButton(
                    context: context,
                    onPressed: () => Navigator.of(context).pop(true),
                    text: 'Clear',
                  ),
                  _buildActionButton(
                    context: context,
                    onPressed: () => Navigator.of(context).pop(false),
                    text: 'Cancel',
                  ),
                ],
              ),
            );

            if (confirm != true) {
              return;
            }

            simulatorManager.clearAll();

            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Simulator state cleared successfully.'),
                ),
              );
            }
          },
        ),
      );
}

Widget _buildActionButton({
  required BuildContext context,
  required String text,
  required VoidCallback onPressed,
}) =>
    TextButton(
      onPressed: onPressed,
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
