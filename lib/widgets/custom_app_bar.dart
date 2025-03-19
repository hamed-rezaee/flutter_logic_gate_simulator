import 'package:flutter/material.dart';
import 'package:flutter_logic_gate_simulator/simulator_file_handler.dart';
import 'package:flutter_logic_gate_simulator/simulator_manager.dart';
import 'package:flutter_logic_gate_simulator/simulator_serializer.dart';

class CustomAppBar extends PreferredSize {
  CustomAppBar({
    this.title = 'Logic Gate Simulator',
    this.simulatorManager,
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
                if (simulatorManager != null) ...[
                  ClearButton(simulatorManager: simulatorManager),
                  SaveButton(simulatorManager: simulatorManager),
                  LoadButton(simulatorManager: simulatorManager),
                  ExportButton(simulatorManager: simulatorManager),
                  ImportButton(simulatorManager: simulatorManager),
                ],
              ],
            ),
          ),
        );

  final String title;
  final SimulatorManager? simulatorManager;

  static const double height = 60;
}

class ClearButton extends StatelessWidget {
  const ClearButton({required this.simulatorManager, super.key});

  final SimulatorManager simulatorManager;

  @override
  Widget build(BuildContext context) => TextButton(
        child:
            const Icon(Icons.cleaning_services, size: 24, color: Colors.white),
        onPressed: () async {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              content: const Text(
                'Are you sure you want to clear the current simulator state?',
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
                    'Clear',
                    style: TextStyle(color: Colors.white),
                  ),
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
                duration: Duration(seconds: 2),
              ),
            );
          }
        },
      );
}

class SaveButton extends StatelessWidget {
  const SaveButton({required this.simulatorManager, super.key});

  final SimulatorManager simulatorManager;

  @override
  Widget build(BuildContext context) => TextButton(
        child: const Icon(Icons.save, size: 24, color: Colors.white),
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

class ExportButton extends StatelessWidget {
  const ExportButton({required this.simulatorManager, super.key});

  final SimulatorManager simulatorManager;

  @override
  Widget build(BuildContext context) => TextButton(
        child: const Icon(Icons.file_download, size: 24, color: Colors.white),
        onPressed: () async {
          if (simulatorManager.components.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Nothing to export. Create a simulation first.'),
                duration: Duration(seconds: 2),
              ),
            );
            return;
          }

          final result = await showDialog<String?>(
            context: context,
            builder: (context) => _ExportDialog(),
          );

          if (result == null || !context.mounted) return;

          final success = await SimulatorFileHandler.exportToFile(
            context,
            simulatorManager,
            fileName: result.isNotEmpty ? '$result.lgs' : null,
          );

          if (context.mounted && success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Simulator state exported successfully.'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        },
      );
}

class ImportButton extends StatelessWidget {
  const ImportButton({required this.simulatorManager, super.key});

  final SimulatorManager simulatorManager;

  @override
  Widget build(BuildContext context) => TextButton(
        child: const Icon(Icons.file_upload, size: 24, color: Colors.white),
        onPressed: () async {
          if (simulatorManager.components.isNotEmpty) {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                content: const Text(
                  'Importing will replace your current simulator state, are you sure?',
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
                      'Import',
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

          if (!context.mounted) return;

          final success = await SimulatorFileHandler.importFromFile(
            context,
            simulatorManager,
          );

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  success
                      ? 'Simulator state imported successfully.'
                      : 'Failed to import simulator state.',
                ),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        },
      );
}

class _ExportDialog extends StatefulWidget {
  @override
  _ExportDialogState createState() => _ExportDialogState();
}

class _ExportDialogState extends State<_ExportDialog> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('Export Simulator State'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter a name for your exported file:'),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'File name',
                labelText: 'File name',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 8),
            const Text(
              'File will be saved with .lgs extension',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(_controller.text),
            child: const Text('Export', style: TextStyle(color: Colors.white)),
          ),
        ],
      );

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }
}
