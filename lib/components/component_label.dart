import 'package:flutter/material.dart';

class ComponentLabel extends StatelessWidget {
  const ComponentLabel({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context) => Text(
        title.toUpperCase(),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 10,
          color: Colors.grey[400],
          fontWeight: FontWeight.bold,
        ),
      );
}
