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
                  SaveAction(simulatorManager: simulatorManager),
                  LoadAction(simulatorManager: simulatorManager),
                  ExportAction(simulatorManager: simulatorManager),
                  ImportAction(simulatorManager: simulatorManager),
                  ClearAction(simulatorManager: simulatorManager),
                ],
              ],
            ),
          ),
        );

  final String title;
  final SimulatorManager? simulatorManager;

  static const double height = 60;
}

class SaveAction extends StatelessWidget {
  const SaveAction({required this.simulatorManager, super.key});

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

          final success = await SimulatorSerializer.save(simulatorManager);

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
      );
}

class LoadAction extends StatelessWidget {
  const LoadAction({required this.simulatorManager, super.key});

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

          final success = await SimulatorSerializer.load(simulatorManager);

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
      );
}

class ExportAction extends StatelessWidget {
  const ExportAction({required this.simulatorManager, super.key});

  final SimulatorManager simulatorManager;

  @override
  Widget build(BuildContext context) => TextButton(
        child: const Icon(Icons.file_download, size: 24, color: Colors.white),
        onPressed: () async {
          if (simulatorManager.components.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Nothing to export. Create a simulation first.'),
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
              ),
            );
          }
        },
      );
}

class ImportAction extends StatelessWidget {
  const ImportAction({required this.simulatorManager, super.key});

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
          _buildActionButton(
            context: context,
            onPressed: () => Navigator.of(context).pop(_controller.text),
            text: 'Export',
          ),
          _buildActionButton(
            context: context,
            onPressed: () => Navigator.of(context).pop(),
            text: 'Cancel',
          ),
        ],
      );

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }
}

class ClearAction extends StatelessWidget {
  const ClearAction({required this.simulatorManager, super.key});

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
