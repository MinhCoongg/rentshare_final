import 'package:flutter/material.dart';
import 'package:rentshare_app/viewmodels/post_product_viewmodel.dart';
class AddPolicyDialog extends StatelessWidget {
  final PostProductViewModel vm;

  const AddPolicyDialog({super.key, required this.vm});
  @override
  Widget build(BuildContext context) {
    final typeController = TextEditingController();
    final contentController = TextEditingController();

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: const Text(
        "Thêm chính sách mới", 
        style: TextStyle(fontWeight: FontWeight.bold)
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildDialogTextField(
            label: "Loại chính sách",
            hint: "VD: Thời gian thuê, Trễ hạn...",
            onChanged: (v) => typeController.text = v,
          ),
          const SizedBox(height: 15),
          _buildDialogTextField(
            label: "Nội dung chi tiết",
            hint: "VD: Tối thiểu 1 ngày...",
            maxLines: 3,
            onChanged: (v) => contentController.text = v,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Hủy", style: TextStyle(color: Colors.grey)),
        ),
        // ElevatedButton(
        //   style: ElevatedButton.styleFrom(
        //     backgroundColor: const Color(0xFF1976D2),
        //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        //   ),
        //   // onPressed: () {
        //   //   if (typeController.text.isNotEmpty && contentController.text.isNotEmpty) {
        //   //     vm.addPolicy(typeController.text, contentController.text);
        //   //     Navigator.pop(context);
        //   //   }
        //   // },
        //   child: const Text("Thêm ngay", style: TextStyle(color: Colors.white)),
        // ),
      ],
    );
  }

  Widget _buildDialogTextField({
    required String label, 
    String? hint, 
    int maxLines = 1, 
    required Function(String) onChanged
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 8),
        TextField(
          maxLines: maxLines,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(12),
          ),
        ),
      ],
    );
  }
}