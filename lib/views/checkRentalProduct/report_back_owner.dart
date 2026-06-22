import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:rentshare_app/models/policy_model.dart';
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
  String _status = 'Good';
  File? _image;
  final ImagePicker _picker = ImagePicker();
  List<PolicyModel> _policies = [];
  final TextEditingController _note = TextEditingController();
  final TextEditingController _fee = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPolicies();
  }

  Future<void> _loadPolicies() async {
    int pId = widget.order.items[0].productId;
    debugPrint("ProductId is: $pId");
    final data = await context.read<RentalOrderViewModel>().fetchPolicies(4);
    debugPrint("Số lượng chính sách lấy được: ${data.length}");
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
      appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black),
          title: const Text("Nhập nghiệm thu sản phẩm", style: TextStyle(color: Colors.black, fontSize: 18))),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _step == 1 ? _buildStep1() : _buildStep2(),
            ),
          ),
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
          _option("Sản phẩm còn tốt", "Không mất phí", "Good"),
          _option("Trầy xước nhẹ", "Gợi ý phí: 20.000đ - 50.000đ", "Damaged"),
          _option("Hư hỏng", "Phí: 50.000đ - 150.000đ", "Broken"),
          const SizedBox(height: 24),
          if (_policies.isNotEmpty) ...[
            const Text("Chính sách hư hỏng & đền bù:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
            const SizedBox(height: 12),
            Table(
              border: TableBorder.all(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(8)),
              columnWidths: const {0: FlexColumnWidth(1), 1: FlexColumnWidth(2)},
              children: [
                TableRow(decoration: BoxDecoration(color: Colors.grey.shade100), children: [
                  _buildTableCell("Tình trạng", isHeader: true),
                  _buildTableCell("Mô tả / Phí", isHeader: true),
                ]),
                ..._policies.map((p) => TableRow(children: [
                  _buildTableCell(p.policyType),
                  _buildTableCell(p.content),
                ])),
              ],
            ),
            const SizedBox(height: 24),
          ],
          const Text("2. Mô tả chi tiết", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          TextField(controller: _note, maxLines: 3, decoration: InputDecoration(hintText: "Nhập chi tiết hư hỏng...", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
        ],
      );

  Widget _buildStep2() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("2. Ảnh/Video làm bằng chứng *", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _pickImage,
            child: DottedBorder(
              borderType: BorderType.RRect, radius: const Radius.circular(12), color: Colors.deepPurple,
              child: Container(height: 120, width: double.infinity, color: Colors.grey[50],
                child: _image != null ? Image.file(_image!, fit: BoxFit.cover) : const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.camera_alt, color: Colors.deepPurple), Text("Thêm ảnh/video")]),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text("3. Chi phí đền bù đề xuất (VNĐ) *", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          TextField(controller: _fee, keyboardType: TextInputType.number, decoration: InputDecoration(prefixText: "VNĐ: ", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
        ],
      );

  Widget _buildTableCell(String text, {bool isHeader = false}) => Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(text, style: TextStyle(fontSize: 11, fontWeight: isHeader ? FontWeight.bold : FontWeight.normal)));

  Widget _option(String title, String sub, String val) => InkWell(
        onTap: () => setState(() => _status = val),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: _status == val ? Colors.deepPurple.withOpacity(0.05) : Colors.transparent, border: Border.all(color: _status == val ? Colors.deepPurple : Colors.grey[300]!), borderRadius: BorderRadius.circular(12)),
          child: Row(children: [Icon(_status == val ? Icons.radio_button_checked : Icons.radio_button_off, color: Colors.deepPurple), const SizedBox(width: 12), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.bold)), Text(sub, style: const TextStyle(fontSize: 12, color: Colors.grey))])]),
        ),
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
                  if (_step == 1) setState(() => _step = 2);
                  else {
                    bool success = await context.read<RentalOrderViewModel>().sendDamageReport(widget.order.id, "Tình trạng: $_status. Ghi chú: ${_note.text}", double.tryParse(_fee.text) ?? 0, _image);
                    if (success) {
                      Navigator.pushReplacement(
                        context, 
                        MaterialPageRoute(builder: (_) => const ReportSuccessScreen())
                      );
                    }
                  }
                },
                child: Text(_step == 1 ? "Tiếp tục" : "Gửi báo cáo", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      );
}