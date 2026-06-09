

import 'package:flutter/material.dart';
import 'package:rentshare_app/utils/sharetoken_utils.dart';
import 'package:rentshare_app/viewmodels/post_product_viewmodel.dart';

class AddAddressDialog extends StatefulWidget {
  final PostProductViewModel vm;

  const AddAddressDialog({super.key, required this.vm});

  @override
  State<AddAddressDialog> createState() => _AddAddressDialogState();
}

class _AddAddressDialogState extends State<AddAddressDialog> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addrController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  bool _isDefaultSelected = false; 

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addrController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        "Thêm địa chỉ mới", 
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                style: const TextStyle(fontSize: 14),
                decoration: const InputDecoration(
                  labelText: "Tên người nhận",
                  hintText: "Ví dụ: Nguyễn Văn A, Nhà riêng, Công ty...",
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                validator: (v) => v!.trim().isEmpty ? "Vui lòng điền tên người nhận" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                style: const TextStyle(fontSize: 14),
                decoration: const InputDecoration(
                  labelText: "Số điện thoại liên hệ",
                  hintText: "Nhập số điện thoại...",
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                validator: (v) => v!.trim().isEmpty ? "Vui lòng điền số điện thoại" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _addrController,
                maxLines: 2,
                style: const TextStyle(fontSize: 14),
                decoration: const InputDecoration(
                  labelText: "Địa chỉ chi tiết",
                  hintText: "Số nhà, tên đường, phường, quận...",
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                validator: (v) => v!.trim().isEmpty ? "Vui lòng điền địa chỉ" : null,
              ),
              const SizedBox(height: 12),
              
              CheckboxListTile(
                title: const Text(
                  "Đặt làm địa chỉ kho mặc định", 
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)
                ),
                contentPadding: EdgeInsets.zero,
                value: _isDefaultSelected,
                activeColor: const Color(0xFF1976D2),
                controlAffinity: ListTileControlAffinity.leading,
                onChanged: (bool? value) {
                  setState(() {
                    _isDefaultSelected = value ?? false;
                  });
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Hủy", style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1976D2),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () async {
            if (_formKey.currentState!.validate()) {

              bool isSuccess = await widget.vm.addNewAddressToBook(
                name: _nameController.text,
                phone: _phoneController.text,
                address: _addrController.text,
                isDefault: _isDefaultSelected,
              );
              
              if (isSuccess && context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Thêm địa chỉ thành công!"),
                     backgroundColor: Color(0xff1B8A4B),
                  ),
                  
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      widget.vm.addressErrorMessage ?? "Có lỗi xảy ra",
                    ),
                     backgroundColor: Color(0xff1B8A4B),
                  ),
                );
              }
            }
          },
          child: const Text("Xác nhận", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}