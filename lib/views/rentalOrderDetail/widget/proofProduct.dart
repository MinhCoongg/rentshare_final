import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:rentshare_app/viewmodels/rental_order_viewmodel.dart';

class ReturnOrderScreen extends StatefulWidget {
  final int orderId;
  const ReturnOrderScreen({super.key, required this.orderId});
  @override
  State<ReturnOrderScreen> createState() => _ReturnOrderScreenState();
}

class _ReturnOrderScreenState extends State<ReturnOrderScreen> {
  final _trackingController = TextEditingController();
  final _noteController = TextEditingController();
  List<XFile> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImages() async {
    final List<XFile> images = await _picker.pickMultiImage();
    setState(() => _selectedImages.addAll(images));
  }

  Widget _buildSection(String title, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<RentalOrderViewModel>(context);
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text("Xác nhận trả hàng", style: TextStyle(color: Colors.black)), backgroundColor: Colors.white, elevation: 0, iconTheme: const IconThemeData(color: Colors.black)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFF5F3FF), borderRadius: BorderRadius.circular(8)), child: const Row(children: [Icon(Icons.info_outline, color: Colors.deepPurple), SizedBox(width: 8), Expanded(child: Text("Vui lòng cung cấp thông tin và hình ảnh chứng minh bạn đã gửi trả sản phẩm cho chủ shop.", style: TextStyle(fontSize: 12)))])),
            const SizedBox(height: 20),
            
            _buildSection("1. Ảnh chứng minh đã gửi hàng *", _buildImagePicker(vm)),
            const SizedBox(height: 20),
            
            _buildSection("2. Mã vận đơn (nếu có)", TextField(controller: _trackingController, decoration: InputDecoration(hintText: "Nhập mã vận đơn", border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12)))),
            const SizedBox(height: 16),
            
            _buildSection("3. Ghi chú (nếu có)", TextField(controller: _noteController, maxLines: 3, decoration: InputDecoration(hintText: "Nhập ghi chú...", border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), contentPadding: const EdgeInsets.all(12)))),
            
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFFFFFBEB), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFFDE68A))),
              child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [Icon(Icons.check_circle_outline, color: Colors.orange, size: 16), SizedBox(width: 6), Text("Lưu ý quan trọng", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange))]),
                SizedBox(height: 6),
                Text("Thời gian trả hàng sẽ được tính khi shop xác nhận đã nhận được hàng.\n• Vui lòng cung cấp thông tin chính xác để đảm bảo quyền lợi của bạn.", style: TextStyle(fontSize: 12, color: Colors.orange)),
              ]),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6200EE), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
          onPressed: vm.isLoading ? null : () async {
            if (_selectedImages.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Vui lòng chọn ít nhất 1 ảnh bằng chứng!"), backgroundColor: Colors.red));
              return;
            }
            final result = await vm.submitReturnFromRenter(
              widget.orderId, 
              File(_selectedImages.first.path), 
              _trackingController.text, 
              _noteController.text
            );

            if (context.mounted) {
              if (result['success'] == true) {
                debugPrint("Trả hàng thành công!");
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Báo trả hàng thành công!"), backgroundColor: Colors.green));
                Navigator.pop(context, true);
              } else {
                debugPrint("Lỗi server: ${result['message']}");
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['message'] ?? "Có lỗi xảy ra!"), backgroundColor: Colors.red));
              }
            }
          },
          child: vm.isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("Xác nhận trả hàng", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildImagePicker(RentalOrderViewModel vm) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      children: [
        GestureDetector(
          onTap: _pickImages,
          child: Container(
            decoration: BoxDecoration(color: const Color(0xFFF1F8FF), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFD0E7FF))),
            child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add_a_photo_outlined, color: Color(0xFF1976D2)), Text("Thêm ảnh")]),
          ),
        ),
        ..._selectedImages.map((file) => Stack(
          children: [
            Positioned.fill(child: ClipRRect(borderRadius: BorderRadius.circular(12), child: kIsWeb ? Image.network(file.path, fit: BoxFit.cover) :Image.file(File(file.path), fit: BoxFit.cover)  )),
            Positioned(right: 4, top: 4, child: GestureDetector(onTap: () => setState(() => _selectedImages.remove(file)), child: const CircleAvatar(radius: 10, backgroundColor: Colors.red, child: Icon(Icons.close, size: 12, color: Colors.white))))
          ],
        )),
      ],
    );
  }
}