import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:rentshare_app/models/policy_model.dart';
import 'package:rentshare_app/models/rentalOrderDetail.dart';
import 'package:rentshare_app/utils/format_utils.dart';
import 'package:rentshare_app/viewmodels/rental_order_viewmodel.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:rentshare_app/views/checkRentalProduct/widget/show.dart';

class NghiemThuProductScreen extends StatefulWidget {
  final dynamic order;
  const NghiemThuProductScreen({super.key, required this.order});

  @override
  State<NghiemThuProductScreen> createState() => _NghiemThuProductScreenState();
}

class _NghiemThuProductScreenState extends State<NghiemThuProductScreen> {
  int _step = 1;
  Set<String> _selectedIssues = {}; 
  double? _selectedDamagePercent;
  File? _image;
  final ImagePicker _picker = ImagePicker();
  OrderDetailItem get currentItem => widget.order.items[0];
  List<PolicyModel> _policies = [];
  final TextEditingController _note = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPolicies();
  }

  Future<void> _loadPolicies() async {
    int pId = widget.order.items[0].productId;
    final data = await context.read<RentalOrderViewModel>().fetchPolicies(pId);
    if (mounted) setState(() => _policies = data);
  }

  Future<void> _pickImage() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _image = File(picked.path));
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0, iconTheme: const IconThemeData(color: Colors.black), title: const Text("Nghiệm thu", style: TextStyle(color: Colors.black))),
      body: Column(
        children: [
          Expanded(child: SingleChildScrollView(padding: const EdgeInsets.all(20), child: _step == 1 ? _buildStep1() : _buildStep2())),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildStep1() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text("1. Tình trạng sản phẩm *", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 16),
      _buildStatusOptions(),
      const SizedBox(height: 24),
      const Text("2. Mô tả chi tiết", style: TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 10),
      TextField(controller: _note, maxLines: 3, decoration: InputDecoration(hintText: "Nhập chi tiết...", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
    ],
  );

  Widget _buildStep2() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text("2. Ảnh làm bằng chứng *", style: TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 12),
      _image == null ? GestureDetector(onTap: _pickImage, child: DottedBorder(borderType: BorderType.RRect, radius: const Radius.circular(12), color: Colors.deepPurple, child: Container(height: 120, width: double.infinity, color: Colors.grey[50], child: const Center(child: Text("Thêm ảnh")))))
        : Stack(children: [ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(_image!, height: 120, width: double.infinity, fit: BoxFit.cover)), Positioned(right: 8, top: 8, child: GestureDetector(onTap: () => setState(() => _image = null), child: const CircleAvatar(radius: 12, backgroundColor: Colors.red, child: Icon(Icons.close, size: 16, color: Colors.white))))]),
      const SizedBox(height: 20),
      const Text("3. Chi phí đền bù (Tự động tính) *", style: TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 10),
        Text(
          "${FormatUtils.formatMoney(_calculateTotalFee())} VNĐ",
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.deepPurple),
        ),
    ],
  );

  Widget _buildFooter() => Container(
    padding: const EdgeInsets.all(20),
    child: Row(
      children: [
        if (_step == 2) Expanded(child: OutlinedButton(onPressed: () => setState(() => _step = 1), child: const Text("Quay lại"))),
        if (_step == 2) const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, padding: const EdgeInsets.symmetric(vertical: 16)),
            onPressed: () async {
              if (_selectedIssues.contains('Good') && _selectedIssues.length == 1) {
                bool success = await context.read<RentalOrderViewModel>().sendDamageReport(widget.order.id, "Tình trạng: Tốt.", 0, null);
                if (success && mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ReportSuccessScreen()));
              } else {
                if (_step == 1) setState(() => _step = 2);
                else {
                  if (_selectedIssues.contains('Broken') && _selectedDamagePercent == null) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Vui lòng chọn mức độ hư hỏng!")));
                    return;
                  }
                 int finalFee = _calculateTotalFee().toInt();
                  bool success = await context.read<RentalOrderViewModel>().sendDamageReport(widget.order.id, "Tình trạng: ${_selectedIssues.join(', ')}. Ghi chú: ${_note.text}", finalFee.toDouble(), _image);
                  if (success && mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ReportSuccessScreen()));
                }
              }
            },
            child: Text(_selectedIssues.contains('Good') && _selectedIssues.length == 1 ? "Hoàn tất" : (_step == 1 ? "Tiếp tục" : "Gửi báo cáo")),
          ),
        ),
      ],
    ),
  );

  Widget _buildStatusOptions() {
    final damagePolicy = _policies.firstWhere((p) => p.type == "Hư hỏng", orElse: () => PolicyModel(type: "Hư hỏng", lightDamage: 10, mediumDamage: 40, heavyDamage: 90));
    return Column(
      children: [
        _buildCheckboxItem("Sản phẩm còn tốt", "Không mất phí", "Good", damagePolicy),
        _buildCheckboxItem("Trễ hạn", "Phạt theo quy định", "Late", damagePolicy),
        _buildCheckboxItem("Hư hỏng", "Phí: Tùy mức độ", "Broken", damagePolicy),
      ],
    );
  }

  Widget _buildCheckboxItem(String title, String sub, String val, PolicyModel damagePolicy) {
    bool isChecked = _selectedIssues.contains(val);
    return Column(
      children: [
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(sub, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          value: isChecked,
          activeColor: Colors.deepPurple,
          onChanged: (bool? value) {
            setState(() {
              if (value == true) {
                if (val == "Broken") {
                  _selectedIssues.remove("Good");
                } else if (val == "Good") {
                  _selectedIssues.remove("Broken");
                }
                _selectedIssues.add(val);
              } else {
                _selectedIssues.remove(val);
              }
            });
          },
        ),

        if (val == "Late" && isChecked)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(8)),
              child: Text(
                "Sản phẩm trễ $_calculatedLateDays ngày theo hệ thống", 
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
              ),
            ),
          ),
        if (val == "Broken" && isChecked) _buildDamageButtons(damagePolicy),
      ],
    );
  }

 Widget _buildDamageButtons(PolicyModel damagePolicy) {
  return Padding(
    padding: const EdgeInsets.only(left: 48, bottom: 16),
    child: Row(
      children: [
        Expanded(child: _buildPercentButton("Nhẹ", damagePolicy.lightDamage ?? 10)),
        const SizedBox(width: 8),
        Expanded(child: _buildPercentButton("Vừa", damagePolicy.mediumDamage ?? 40)),
        const SizedBox(width: 8),
        Expanded(child: _buildPercentButton("Nặng", damagePolicy.heavyDamage ?? 90)),
      ],
    ),
  );
}

  Widget _buildPercentButton(String label, double percent) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(side: BorderSide(color: _selectedDamagePercent == percent ? Colors.deepPurple : Colors.grey[300]!), backgroundColor: _selectedDamagePercent == percent ? Colors.deepPurple.withOpacity(0.1) : null),
      onPressed: () => setState(() => _selectedDamagePercent = percent),
      child: Text("$label (${percent.toInt()}%)"),
    );
  }


  int get _calculatedLateDays {
    try {
      List<String> parts = widget.order.endDateFormatted.split('/');
      DateTime endDate = DateTime(
        int.parse(parts[2]), // Năm
        int.parse(parts[1]), // Tháng
        int.parse(parts[0]), // Ngày
      );
      
      DateTime now = DateTime.now();
      if (now.isAfter(endDate)) {
        return now.difference(endDate).inDays;
      }
    } catch (e) {
      debugPrint("Lỗi parse ngày: $e");
      return 0;
    }
    return 0;
  }

  double _calculateTotalFee() {
    double deposit = double.tryParse(currentItem.depositAmount) ?? 0;
    double damageFine = _selectedIssues.contains('Broken') 
        ? (deposit * (_selectedDamagePercent ?? 0) / 100) 
        : 0;
    final latePolicy = _policies.firstWhere(
      (p) => p.type == "Trễ hạn", 
      orElse: () => PolicyModel(type: "Trễ hạn", fineValue: 0, unit: 'VND')
    );

    double lateFine = 0;
    if (_selectedIssues.contains('Late')) {
      if (latePolicy.unit == 'PERCENT') {
        lateFine = _calculatedLateDays * (deposit * latePolicy.fineValue / 100);
      } else {
        lateFine = _calculatedLateDays * latePolicy.fineValue;
      }
    }
    return (damageFine + lateFine).roundToDouble();
  }
}