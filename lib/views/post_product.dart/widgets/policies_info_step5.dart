import 'package:flutter/material.dart';
import 'package:rentshare_app/viewmodels/post_product_viewmodel.dart';

class Step5PoliciesInfo extends StatelessWidget {
  final PostProductViewModel vm;

  const Step5PoliciesInfo({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    const List<String> policyTypesList = ["Hủy đơn", "Trễ hạn", "Hư hỏng", "Mất sản phẩm", "Điều kiện thuê", "Khác"];

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16), 
      children: [
        _buildPremiumCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "5. Chính sách thuê", 
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)
              ),
              const SizedBox(height: 6),
              Text(
                "Tự thiết lập các quy định bồi hoàn để người thuê nắm rõ trách nhiệm.",
                style: TextStyle(color: Colors.grey[500], fontSize: 13, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 20),
              if (vm.activePolicies.isEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: Colors.grey[50], shape: BoxShape.circle),
                        child: Icon(Icons.gavel_outlined, size: 40, color: Colors.grey[300]),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Chưa có quy định nào\nBấm nút bên dưới để tự tạo chính sách riêng", 
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[400], fontSize: 13, height: 1.4, fontWeight: FontWeight.w500)
                      ),
                    ],
                  ),
                ),

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: vm.activePolicies.length,
                itemBuilder: (context, index) {
                  final policy = vm.activePolicies[index];
                  
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 8), 
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade100, width: 1.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: _getPolicyColor(policy.type).withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(_getPolicyIcon(policy.type), color: _getPolicyColor(policy.type), size: 16),
                            ),
                            const SizedBox(width: 10),
                            
                            Expanded(
                              child: DropdownButtonHideUnderline(
                                child: DropdownButtonFormField<String>(
                                  value: policyTypesList.contains(policy.type) ? policy.type : "Khác",
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                                  decoration: const InputDecoration(
                                    contentPadding: EdgeInsets.zero,
                                    border: InputBorder.none,
                                  ),
                                  icon: const Icon(Icons.arrow_drop_down, color: Colors.black54),
                                  items: policyTypesList.map((String type) {
                                    return DropdownMenuItem<String>(
                                      value: type,
                                      child: Text(type),
                                    );
                                  }).toList(),
                                  onChanged: (value) => vm.updatePolicyType(index, value!),
                                ),
                              ),
                            ),
                            
                            IconButton(
                              constraints: const BoxConstraints(),
                              padding: EdgeInsets.zero,
                              icon: Icon(Icons.cancel_rounded, color: Colors.grey.shade400, size: 20),
                              onPressed: () => vm.removePolicyField(index),
                            )
                          ],
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          key: ValueKey("user_policy_$index"),
                          initialValue: policy.content,
                          maxLines: 3,
                          minLines: 2,
                          keyboardType: TextInputType.multiline,
                          style: const TextStyle(fontSize: 13, color: Colors.black87, height: 1.4, fontWeight: FontWeight.w500),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFFFAFAFA),
                            hintText: _getPolicyHint(policy.type),
                            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
                            contentPadding: const EdgeInsets.all(12),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF1976D2), width: 1.5)),
                          ),
                          onChanged: (v) => vm.updatePolicyContent(index, v),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () => vm.addNewPolicyField(),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 48,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF1976D2).withOpacity(0.4), width: 1.5),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_circle_outline_rounded, size: 18, color: Color(0xFF1976D2)),
                      SizedBox(width: 8),
                      Text(
                        "Thêm chính sách mới", 
                        style: TextStyle(color: Color(0xFF1976D2), fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F8FD),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.verified_user_outlined, color: Color(0xFF1976D2), size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Quy định minh bạch", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
                          const SizedBox(height: 4),
                          Text(
                            "Nội dung này sẽ hiển thị trực tiếp ở trang chi tiết sản phẩm. Hãy ghi rõ ràng để bảo vệ quyền lợi món đồ.",
                            style: TextStyle(color: Colors.grey[600], fontSize: 12, height: 1.4, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  IconData _getPolicyIcon(String type) {
    switch (type) {
      case "Hủy đơn": return Icons.calendar_today_rounded;
      case "Trễ hạn": return Icons.schedule_rounded;
      case "Hư hỏng": return Icons.gpp_bad_rounded;
      case "Mất sản phẩm": return Icons.error_outline_rounded;
      case "Điều kiện thuê": return Icons.assignment_ind_rounded;
      default: return Icons.more_horiz_rounded;
    }
  }

  Color _getPolicyColor(String type) {
    switch (type) {
      case "Hủy đơn": return Colors.teal;
      case "Trễ hạn": return Colors.orange;
      case "Hư hỏng": return Colors.redAccent;
      case "Mất sản phẩm": return Colors.purple;
      case "Điều kiện thuê": return Colors.blue;
      default: return Colors.blueGrey;
    }
  }

  String _getPolicyHint(String type) {
    switch (type) {
      case "Hủy đơn": return "Ví dụ: Hoàn tiền 100% nếu chủ động hủy trước 24 giờ...";
      case "Trễ hạn": return "Ví dụ: Phí trễ hạn phạt thêm 50.000đ cho mỗi ngày trả muộn...";
      case "Hư hỏng": return "Ví dụ: Mọi vết trầy xước nặng do lỗi cố ý sẽ trừ thẳng vào cọc...";
      case "Mất sản phẩm": return "Ví dụ: Đền bù 100% giá trị gốc của thiết bị theo giá thị trường...";
      case "Điều kiện thuê": return "Ví dụ: Bắt buộc xuất trình CCCD gốc và ký biên bản giao nhận...";
      default: return "Nhập nội dung quy chế riêng tư của ní...";
    }
  }

  Widget _buildPremiumCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: child,
    );
  }
}