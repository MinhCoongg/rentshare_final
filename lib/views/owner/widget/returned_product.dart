import 'package:flutter/material.dart';

class ReturnVerificationSection extends StatelessWidget {
  final dynamic order;

  const ReturnVerificationSection({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    if (order.status != 'Returned') return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB), 
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.receipt_long, color: Color(0xFF6200EE), size: 20),
              const SizedBox(width: 8),
              const Text("Thông tin gửi trả hàng", 
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1F2937))),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, thickness: 1, color: Color(0xFFE5E7EB)),
          ),
          
          if (order.returnProof != null && order.returnProof!.isNotEmpty) ...[
            const Text("Hình ảnh chứng minh:", style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () { },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network('${order.returnProof!}', height: 160, width: double.infinity, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 16),
          ],
          
          _buildInfoRow("Mã vận đơn:", order.trackingNumber ?? "Không có", isBold: true),
          const SizedBox(height: 8),
          _buildInfoRow("Ghi chú khách:", order.note ?? "Không có", isMultiLine: true),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isBold = false, bool isMultiLine = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 100, child: Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey))),
        Expanded(
          child: Text(value, 
            style: TextStyle(fontSize: 13, fontWeight: isBold ? FontWeight.bold : FontWeight.w500, color: const Color(0xFF111827))),
        ),
      ],
    );
  }
}