import 'package:flutter/material.dart';
class StatCard extends StatelessWidget {
  final String title;
  final String count;
  final Color color;
  final IconData icon;

  const StatCard({
    super.key,
    required this.title,
    required this.count,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 30, color: color.withOpacity(0.5)),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min, 
            children: [
              Text(
                count, 
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)
              ),
              Text(title, style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }
}