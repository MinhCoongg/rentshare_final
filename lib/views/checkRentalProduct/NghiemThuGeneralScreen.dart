import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:rentshare_app/models/ReportData.dart';
import 'package:rentshare_app/models/policy_model.dart';
import 'package:rentshare_app/viewmodels/rental_order_viewmodel.dart';

class NghiemThuGeneralScreen extends StatefulWidget {
  final dynamic order;
  const NghiemThuGeneralScreen({super.key, required this.order});

  @override
  State<NghiemThuGeneralScreen> createState() => _NghiemThuGeneralScreenState();
}

class _NghiemThuGeneralScreenState extends State<NghiemThuGeneralScreen> {
  Map<int, ReportData> _reports = {};
  List<PolicyModel> _policies = [];
  Set<String> _selectedIssues = {}; 
  double? _selectedDamagePercent;
  
  Future<void> _loadPolicies() async {
    int pId = widget.order.items[0].productId;
    final data = await context.read<RentalOrderViewModel>().fetchPolicies(pId);
    if (mounted) setState(() => _policies = data);
  }

  @override
  void initState() {
    super.initState();
    _loadPolicies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(title: const Text("Nghiệm thu đơn hàng"), backgroundColor: Colors.white, foregroundColor: Colors.black),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: widget.order.items.length,
              itemBuilder: (context, index) {
                var item = widget.order.items[index];
                return _buildProductCard(item);
              },
            ),
          ),
          _buildBottomSummary(),
        ],
      ),
    );
  }

  Widget _buildProductCard(dynamic item) {
  ReportData report = _reports[item.productId] ??= ReportData(
    productId: item.productId, 
    deposit: double.parse(item.depositAmount.toString()), 
    latePolicy: _getPolicyForProduct(item, "Trễ hạn")
  );
 final damagePolicy = _policies.firstWhere(
    (p) => p.productId == item.productId && p.type == "Hư hỏng", 
    orElse: () => PolicyModel(type: "Hư hỏng", lightDamage: 10, mediumDamage: 40, heavyDamage: 90)
  );

  return Card(
    margin: const EdgeInsets.only(bottom: 12),
    child: Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER: Ảnh + Tên + Tiền cọc
          Row(
            children: [
              ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(item.image ?? '', width: 60, height: 60, fit: BoxFit.cover)),
              const SizedBox(width: 12),
              Expanded(child: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold))),
            ],
          ),
          const Divider(),
          

          CheckboxListTile(
            title: const Text("Sản phẩm còn tốt"),
            value: report.isGood,
            activeColor: Colors.deepPurple,
            onChanged: (v) => setState(() {
              report.isGood = v!;
              if (report.isGood) { 
                report.isLate = false;
                report.isBroken = false;
              }
              _reports[report.productId] = report;
            }),
          ),
          CheckboxListTile(
            title: const Text("Trễ hạn"),
            value: report.isLate,
            activeColor: Colors.deepPurple,
            onChanged: (v) => setState(() {
              report.isLate = v!;
              if (report.isLate) report.isGood = false;
              _reports[report.productId] = report;
            }),
          ),
          CheckboxListTile(
            title: const Text("Hư hỏng"),
            value: report.isBroken,
            activeColor: Colors.deepPurple,
            onChanged: (v) => setState(() {
              report.isBroken = v!;
              if (report.isBroken) report.isGood = false; 
              _reports[report.productId] = report;
            }),
          ),

    
          // 1. Hiện nút chọn mức độ (Chỉ hiện khi Hư hỏng)
          if (report.isBroken) 
            _buildDamageButtons(damagePolicy, report),

          // 2. Hiện Ghi chú và Ảnh (Hiện nếu Trễ HOẶC Hư hỏng)
          if (report.isLate || report.isBroken) ...[
            const SizedBox(height: 10),
            const Text("Ghi chú:", style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(
              decoration: const InputDecoration(hintText: "Nhập chi tiết...", border: OutlineInputBorder()),
              onChanged: (v) => setState(() => report.note = v),
            ),
            const SizedBox(height: 10),
            _buildImagePicker(report),
          ],
          
          Text("Chi phí: ${report.calculateFee()}đ", style: const TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold)),
        ],
      ),
    ),
  );
}

  


  PolicyModel _getPolicyForProduct(dynamic item, String type) {
    return _policies.firstWhere((p) => p.productId == item.productId && p.type == type, 
      orElse: () => PolicyModel(type: type, fineValue: 0, unit: 'VND'));
  }

  Widget _buildBottomSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Tổng chi phí đền bù (dự kiến):", style: TextStyle(fontWeight: FontWeight.bold)),
              Text("${_calculateTotalOrderFee()}đ", style: const TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () { /* Gọi API gửi danh sách _reports đi */ },
              child: const Text("Gửi báo cáo nghiệm thu"),
            ),
          ),
        ],
      ),
    );
  }

  double _calculateTotalOrderFee() {
    double total = 0;
    _reports.forEach((key, report) {
      total += report.calculateFee();
    });
    return total;
  }




  Widget _buildImagePicker(ReportData report) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("3. Ảnh làm bằng chứng *", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        report.image == null 
            ? GestureDetector(
                onTap: () async {
                  final XFile? picked = await ImagePicker().pickImage(source: ImageSource.gallery);
                  if (picked != null) {
                    setState(() => report.image = File(picked.path));
                  }
                },
                child: DottedBorder(
                  borderType: BorderType.RRect,
                  radius: const Radius.circular(12),
                  color: Colors.deepPurple,
                  child: Container(
                    height: 100,
                    width: double.infinity,
                    color: Colors.grey[50],
                    child: const Center(child: Icon(Icons.camera_alt, color: Colors.deepPurple)),
                  ),
                ),
              )
            : Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(report.image!, height: 120, width: double.infinity, fit: BoxFit.cover),
                  ),
                  Positioned(
                    right: 8, top: 8,
                    child: GestureDetector(
                      onTap: () => setState(() => report.image = null),
                      child: const CircleAvatar(radius: 12, backgroundColor: Colors.red, child: Icon(Icons.close, size: 16, color: Colors.white)),
                    ),
                  ),
                ],
              ),
      ],
    );
  }

  // Ní dán cái này vào, tui đã sửa tên thành _buildDamageButtons để khớp với code của ní
Widget _buildDamageButtons(PolicyModel damagePolicy, ReportData report) {
  return Padding(
    padding: const EdgeInsets.only(left: 10, top: 10, bottom: 10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Chọn mức độ hư hỏng:", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _buildPercentButton("Nhẹ", damagePolicy.lightDamage ?? 10, report)),
            const SizedBox(width: 8),
            Expanded(child: _buildPercentButton("Vừa", damagePolicy.mediumDamage ?? 40, report)),
            const SizedBox(width: 8),
            Expanded(child: _buildPercentButton("Nặng", damagePolicy.heavyDamage ?? 90, report)),
          ],
        ),
      ],
    ),
  );
}

// Đảm bảo hàm này cũng có trong class
Widget _buildPercentButton(String label, double percent, ReportData report) {
  return OutlinedButton(
    style: OutlinedButton.styleFrom(
      side: BorderSide(color: report.damagePercent == percent ? Colors.deepPurple : Colors.grey[300]!),
      backgroundColor: report.damagePercent == percent ? Colors.deepPurple.withOpacity(0.1) : null,
    ),
    onPressed: () => setState(() {
      report.damagePercent = percent;
      _reports[report.productId] = report; // Cập nhật lại Map để tính tiền
    }),
    child: Text(label),
  );
}

}