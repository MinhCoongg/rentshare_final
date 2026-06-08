import 'package:flutter/material.dart';
import 'package:rentshare_app/models/product_model.dart';

class PolicyTab extends StatelessWidget {
  final ProductModel item;

  const PolicyTab({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    if (item.policies == null || item.policies.isEmpty) {
      return const Center(
        child: Text("Chưa có chính sách cho sản phẩm này"),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Chính sách thuê",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          ...item.policies!.map((p) => PolicyCard(policy: p)).toList(),

          const SizedBox(height: 100),
        ],
      ),
    );
  }
}

class PolicyCard extends StatelessWidget {
  final dynamic policy; 

  const PolicyCard({super.key, required this.policy});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF0056D2).withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _getIcon(policy.policyType ?? policy.title),
              color: const Color(0xFF0056D2),
              size: 22,
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  policy.policyType ?? policy.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  policy.content,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  IconData _getIcon(String type) {
    final t = type.toLowerCase();
    if (t.contains('thời gian')) return Icons.access_time_rounded;
    if (t.contains('trễ')) return Icons.warning_amber_rounded;
    if (t.contains('cọc')) return Icons.security_outlined;
    if (t.contains('bồi')) return Icons.build_circle_outlined;
    if (t.contains('giao')) return Icons.local_shipping_outlined;
    if (t.contains('hủy')) return Icons.cancel_outlined;
    return Icons.info_outline;
  }
}