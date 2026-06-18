import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentshare_app/viewmodels/addresses_viewmodel.dart';
import 'package:rentshare_app/viewmodels/checkout_viewmodel.dart';

class AddAddressCheckoutDialog extends StatefulWidget {
  final CheckoutViewModel checkoutVM; 

  const AddAddressCheckoutDialog({super.key, required this.checkoutVM});

  @override
  State<AddAddressCheckoutDialog> createState() => _AddAddressCheckoutDialogState();
}

class _AddAddressCheckoutDialogState extends State<AddAddressCheckoutDialog> {
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
    final addressVM = context.watch<AddressViewModel>();

    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text("Thêm địa chỉ nhận hàng mới", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Tên người nhận"),
                validator: (v) => v!.trim().isEmpty ? "Vui lòng điền tên người nhận" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: "Số điện thoại liên hệ"),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return "Vui lòng điền số điện thoại";
                  if (!RegExp(r'^(03|05|07|08|09)\d{8}$').hasMatch(v.trim())) return "Số điện thoại phải có 10 số";
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _addrController,
                maxLines: 2,
                decoration: const InputDecoration(labelText: "Địa chỉ chi tiết"),
                validator: (v) => v!.trim().isEmpty ? "Vui lòng điền địa chỉ" : null,
              ),
              const SizedBox(height: 12),
              CheckboxListTile(
                title: const Text("Đặt làm địa chỉ mặc định", style: TextStyle(fontSize: 13)),
                contentPadding: EdgeInsets.zero,
                value: _isDefaultSelected,
                activeColor: const Color(0xFF4F46E5),
                controlAffinity: ListTileControlAffinity.leading,
                onChanged: (v) => setState(() => _isDefaultSelected = v ?? false),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F46E5)),
          onPressed: addressVM.isLoading
              ? null
              : () async {
                  if (_formKey.currentState!.validate()) {
                    final createdAddress = await context.read<AddressViewModel>().addNewAddress(
                          name: _nameController.text.trim(),
                          phone: _phoneController.text.trim(),
                          address: _addrController.text.trim(),
                          isDefault: _isDefaultSelected,
                        );

                    if (createdAddress != null && context.mounted) {
                      widget.checkoutVM.selectAddressFromBook(createdAddress);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Thêm địa chỉ thành công!"), backgroundColor: Color(0xff1B8A4B)),
                      );
                    } else if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(addressVM.errorMessage ?? "Có lỗi xảy ra"), backgroundColor: Colors.redAccent),
                      );
                    }
                  }
                },
          child: addressVM.isLoading
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text("Xác nhận", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}