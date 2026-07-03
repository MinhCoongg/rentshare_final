import 'package:flutter/material.dart';
import 'package:rentshare_app/models/policy_model.dart';
import 'package:rentshare_app/models/product_model.dart';

class PolicyTab extends StatelessWidget {
  final ProductModel item;

  const PolicyTab({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    if (item.policies.isEmpty) {
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

          ...item.policies.map((p) => PolicyCard(policy: p)),

          const SizedBox(height: 100),
        ],
      ),
    );
  }
}

class PolicyCard extends StatelessWidget {
  final PolicyModel policy; 

  const PolicyCard({super.key, required this.policy});

  @override
  Widget build(BuildContext context) {
    bool isDamagePolicy = policy.type == "Hư hỏng" && policy.lightDamage != null;
    bool hasFineValue = policy.fineValue > 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade50),
        boxShadow: [
          BoxShadow(color: Colors.blue.shade50.withOpacity(0.5), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12)),
                child: Icon(_getIcon(policy.type), color: Colors.blue.shade700, size: 22),
              ),
              const SizedBox(width: 12),
              Text(policy.type, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1)),
          
          if (isDamagePolicy)
            _buildDamageDetails()
          else if (hasFineValue)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Phí trễ hạn: ${policy.fineValue.toInt()}${policy.unit == 'PERCENT' ? '%' : ' VNĐ'}/ngày",
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text(
                  policy.unit == 'PERCENT' 
                    ? "Phí = (Giá trị sản phẩm) × ${policy.fineValue.toInt()}% / ngày"
                    : "Phí cố định: ${policy.fineValue.toInt()} VNĐ / ngày",
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12, fontStyle: FontStyle.italic),
                ),
              ],
            )
          else
            Text(
              _getPolicyExplanation(policy.type), 
              style: TextStyle(
                color: Colors.grey.shade700, 
                fontSize: 14, 
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDamageDetails() {
    return Column(
      children: [
        _buildDamageRow("Hư nhẹ (Trầy xước)", "${policy.lightDamage?.toInt()}%"),
        _buildDamageRow("Hư vừa (Linh kiện)", "${policy.mediumDamage?.toInt()}%"),
        _buildDamageRow("Hư nặng (Không dùng)", "${policy.heavyDamage?.toInt()}%", isLast: true),
      ],
    );
  }

  Widget _buildDamageRow(String label, String value, {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade800, fontSize: 14)),
        ],
      ),
    );
  }

  IconData _getIcon(String type) {
    if (type.contains('Trễ')) return Icons.schedule_rounded;
    if (type.contains('Hư')) return Icons.build_rounded;
    if (type.contains('Hủy')) return Icons.cancel_rounded;
    return Icons.inventory_2_rounded;
  }

  String _getPolicyExplanation(String type) {
    switch (type) {
      case "Hủy đơn":
        return "Chưa duyệt: Hoàn 100% tiền cọc.\nĐã duyệt: Không được hoàn tiền.";
      case "Mất sản phẩm":
        return "Yêu cầu đền bù 100% giá trị sản phẩm theo hóa đơn mua mới tại thời điểm mất.";
      default:
        return "Áp dụng theo quy định của hệ thống RentShare.";
    }
  }
}