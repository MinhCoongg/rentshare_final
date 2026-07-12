import 'package:flutter/material.dart';

class TimelineStep extends StatelessWidget {
  final String label;
  final String time;
  final bool isCompleted;
  final Color activeColor;

  const TimelineStep({
    super.key,
    required this.label,
    this.time = "",
    required this.isCompleted,
    this.activeColor = const Color(0xFF00B4D8),
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
          color: isCompleted ? activeColor : Colors.grey[300],
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal,
            color: isCompleted ? Colors.black : Colors.grey,
          ),
        ),
        if (time.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            time.split(' ')[0],
            style: const TextStyle(fontSize: 9, color: Colors.grey),
          ),
        ],
      ],
    );
  }
}