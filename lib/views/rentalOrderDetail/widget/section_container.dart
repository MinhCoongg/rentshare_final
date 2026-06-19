import 'package:flutter/material.dart';

class SectionContainer extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color primaryColor;
  final Widget child;

  const SectionContainer({
    super.key,
    required this.title,
    required this.icon,
    this.primaryColor = const Color(0xFF00B4D8),
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: primaryColor),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black)),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1, thickness: 0.5, color: Color(0xFFF3F4F6)),
          ),
          child,
        ],
      ),
    );
  }
}