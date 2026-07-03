import 'package:flutter/material.dart';
import 'package:rentshare_app/utils/format_utils.dart';
import 'package:rentshare_app/viewmodels/post_product_viewmodel.dart';
import 'package:rentshare_app/models/policy_model.dart';

class Step5PoliciesInfo extends StatelessWidget {
  final PostProductViewModel vm;
  const Step5PoliciesInfo({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionHeader("Chính sách của bạn (Chỉnh sửa được)"),
        _buildTrerHanCard(),
        const SizedBox(height: 12),
        _buildHuHongCard(),
        const SizedBox(height: 24),
        _buildSectionHeader("Quy định hệ thống (Thông tin)"),
        _buildMatSanPhamCard(),
        const SizedBox(height: 12),
        _buildHuyDonCard(),
        const SizedBox(height: 20),
        _buildLuuYFooter(),
      ],
    );
  }

  Widget _buildSectionHeader(String title) => 
      Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey)));

  Widget _buildTrerHanCard() {
    final policy = vm.activePolicies.firstWhere((p) => p.type == "Trễ hạn");
    final index = vm.activePolicies.indexOf(policy);
    return _buildPolicyCard("Trễ hạn", Icons.schedule, Colors.orangeAccent, [
      _buildModernSegmented(index, policy),
      const SizedBox(height: 16),
      Wrap(spacing: 10, children: (policy.unit == 'PERCENT' ? [5, 10, 15, 20, 25, 30, 50] : [20000, 50000, 100000, 200000]).map((val) => _buildChip(val, index, policy)).toList()),
    ]);
  }


  Widget _buildHuHongCard() {
  return _buildPolicyCard("Hư hỏng", Icons.build, Colors.red, [
    _buildSliderField("Hư nhẹ (Trầy xước)", vm.lightValue, 1, 20, (v) => vm.updateDamageValues(v, vm.mediumValue, vm.heavyValue)),
    _buildSliderField("Hư vừa (Hỏng linh kiện)", vm.mediumValue, 21, 50, (v) => vm.updateDamageValues(vm.lightValue, v, vm.heavyValue)),
    _buildSliderField("Hư nặng (Không dùng được)", vm.heavyValue, 51, 100, (v) => vm.updateDamageValues(vm.lightValue, vm.mediumValue, v)),
  ]);
}

Widget _buildSliderField(String label, double value, double min, double max, Function(double) onChanged) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text("${value.toInt()}%", style: TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold)),
        ],
      ),
      Slider(
        value: value, min: min, max: max, divisions: (max - min).toInt(),
        activeColor: Colors.orangeAccent,
        onChanged: onChanged,
      ),
    ],
  );
}


  

  Widget _buildMatSanPhamCard() => _buildInfoCard("Mất sản phẩm", Icons.inventory, Colors.purple, "Đền bù 100% giá trị sản phẩm theo thị trường.");

  Widget _buildHuyDonCard() => _buildInfoCard("Hủy đơn", Icons.cancel, Colors.teal, "Chưa duyệt: Hoàn 100% | Đã duyệt: Không được hủy.");


  Widget _buildPolicyCard(String title, IconData icon, Color color, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Icon(icon, color: color), SizedBox(width: 8), Text(title, style: TextStyle(fontWeight: FontWeight.bold))]),
        const Divider(),
        ...children,
      ]),
    );
  }

  Widget _buildInfoCard(String title, IconData icon, Color color, String desc) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Icon(icon, color: color), SizedBox(width: 8), Text(title, style: TextStyle(fontWeight: FontWeight.bold))]),
        const SizedBox(height: 8),
        Text(desc, style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
      ]),
    );
  }

  Widget _buildChip(int val, int index, PolicyModel policy) => FilterChip(
    label: Text(policy.unit == 'PERCENT' ? "$val%" : "${FormatUtils.formatMoney(double.parse(val.toString()))}đ"), 
    selected: policy.fineValue == val.toDouble(),
    onSelected: (_) => vm.updatePolicyFineValue(index, val.toDouble()),
    selectedColor: Colors.orange.shade200,
  );

  Widget _buildModernSegmented(int index, PolicyModel policy) => Container(
    padding: EdgeInsets.all(4), 
    decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(10)), 
    child: Row(children: [
      _segmentItem("Cố định", policy.unit == 'VND', () => vm.updatePolicyUnit(index, 'VND')), 
      _segmentItem("Theo %", policy.unit == 'PERCENT', () => vm.updatePolicyUnit(index, 'PERCENT'))
    ])
  );

  Widget _segmentItem(String label, bool isSelected, VoidCallback onTap) => Expanded(child: GestureDetector(onTap: onTap, child: Container(padding: EdgeInsets.symmetric(vertical: 10), decoration: BoxDecoration(color: isSelected ? Colors.white : Colors.transparent, borderRadius: BorderRadius.circular(8)), child: Center(child: Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? Colors.blue.shade700 : Colors.grey))))));
  Widget _buildLuuYFooter() => Container(padding: EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12)), child: Text("💡 Lưu ý: Các chính sách Hủy đơn và Mất sản phẩm được áp dụng theo quy định của hệ thống RentShare.", style: TextStyle(color: Colors.blue.shade800, fontSize: 12)));
}