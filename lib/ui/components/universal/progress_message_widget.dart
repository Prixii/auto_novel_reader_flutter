import 'package:flutter/material.dart';

class ProgressMessageWidget extends StatelessWidget {
  const ProgressMessageWidget({
    super.key,
    required this.progress,
    required this.message,
    this.visible = false,
  });

  final int progress;
  final String message;
  final bool visible;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        LinearProgressIndicator(
          value: progress / 100,
          backgroundColor: Colors.grey[300],
          valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
        ),
        const SizedBox(height: 8.0),
        Text(
          message,
          style: const TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
