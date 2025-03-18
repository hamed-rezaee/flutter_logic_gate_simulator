import 'package:flutter/material.dart';

class CustomAppBar extends PreferredSize {
  CustomAppBar({this.actions, this.title = 'Logic Gate Simulator', super.key})
      : super(
          preferredSize: const Size.fromHeight(height),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            height: 60,
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
                ...?actions,
              ],
            ),
          ),
        );

  final String title;
  final List<Widget>? actions;

  static const double height = 60;
}
