import 'package:flutter/material.dart';

class ComponentInformation extends StatelessWidget {
  const ComponentInformation({required this.information, super.key});

  final String information;

  static const _color = Colors.blueGrey;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: () => _showInformationDialog(context),
        borderRadius: BorderRadius.circular(4),
        child: Center(
          child: Icon(Icons.info_rounded, size: 8, color: Colors.grey[400]),
        ),
      );

  void _showInformationDialog(BuildContext context) {
    final componentName = information.split(':').first.trim();

    showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 450, maxHeight: 450),
          decoration: BoxDecoration(
            color: Colors.grey[850],
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.grey[700]!),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildDialogHeader(componentName, context),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _buildContent(),
                  ),
                ),
              ),
              _buildDialogFooter(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDialogHeader(String title, BuildContext context) => Container(
        decoration: const BoxDecoration(color: _color),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: const Icon(Icons.close, color: Colors.white70, size: 20),
            ),
          ],
        ),
      );

  Widget _buildDialogFooter(BuildContext context) => Container(
        decoration: BoxDecoration(color: Colors.grey[800]),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: _color,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: const Text('Close'),
            ),
          ],
        ),
      );

  List<Widget> _buildContent() {
    final lines = information.split('\n');

    final widgets = <Widget>[];
    var currentSection = '';
    var currentContent = <String>[];

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i].trim();

      if (i == 0) {
        continue;
      } else if (line.endsWith(':')) {
        if (currentSection.isNotEmpty) {
          widgets.add(_buildContentSection(currentSection, currentContent));
          currentContent = [];
        }
        currentSection = line.substring(0, line.length - 1);
      } else if (line.startsWith('\t')) {
        currentContent.add(line.substring(1));
      } else if (line.isNotEmpty) {
        currentContent.add(line);
      }
    }

    if (currentSection.isNotEmpty) {
      widgets.add(_buildContentSection(currentSection, currentContent));
    }

    return widgets;
  }

  Widget _buildContentSection(String title, List<String> content) => Container(
        margin: const EdgeInsets.only(top: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
              decoration: BoxDecoration(
                color: _color.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: _color.withValues(alpha: 0.3)),
              ),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            ...content.map(
              (line) => Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text(
                  line,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[300],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
}
