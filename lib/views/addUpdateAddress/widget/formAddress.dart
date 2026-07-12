import 'package:flutter/material.dart';
import 'package:rentshare_app/models/address_model.dart';
import 'package:rentshare_app/viewmodels/address_viewmodel.dart';

class AddAddressDialog extends StatefulWidget {
  final AddressSelectionViewModel vm;
  final AddressModel? editAddress;

  const AddAddressDialog({super.key, required this.vm, this.editAddress});

  @override
  State<AddAddressDialog> createState() => _AddAddressDialogState();
}

class _AddAddressDialogState extends State<AddAddressDialog> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _addr = TextEditingController();
  bool _isDefault = false;

  @override
  void initState() {
    super.initState();
    if (widget.editAddress != null) {
      _name.text = widget.editAddress!.receiverName;
      _phone.text = widget.editAddress!.receiverPhone;
      _addr.text = widget.editAddress!.fullAddress;
      _isDefault = widget.editAddress!.isDefault;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _addr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isEdit = widget.editAddress != null;
    return AlertDialog(
      title: Text(isEdit ? "Cập nhật địa chỉ" : "Thêm địa chỉ mới"),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _name, 
                decoration: const InputDecoration(labelText: "Tên người nhận"), 
                validator: (v) => v!.isEmpty ? "Vui lòng nhập tên" : null
              ),
              TextFormField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: "Số điện thoại"),
                validator: (v) {
                  final phoneRegex = RegExp(r'^0[0-9]{9}$');
                  
                  if (v == null || v.isEmpty) {
                    return "Vui lòng nhập SĐT";
                  } else if (!phoneRegex.hasMatch(v)) {
                    return "SĐT không hợp lệ (ví dụ: 0912345678)";
                  }
                  return null; // Hợp lệ
                },
              ),
              TextFormField(
                controller: _addr, 
                decoration: const InputDecoration(labelText: "Địa chỉ chi tiết"),
                validator: (v) => v!.isEmpty ? "Vui lòng nhập địa chỉ" : null
              ),
              CheckboxListTile(
                title: const Text("Đặt làm mặc định"), 
                value: _isDefault, 
                onChanged: (v) => setState(() => _isDefault = v!)
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
        ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              bool success = false;
              
              if (isEdit) {
                // Gửi bản sao đã cập nhật lên server
                AddressModel updated = widget.editAddress!.copyWith(
                  receiverName: _name.text,
                  receiverPhone: _phone.text,
                  fullAddress: _addr.text,
                  isDefault: _isDefault,
                );
                success = await widget.vm.updateAddress(updated);
              } else {
                // Thêm mới
                success = await widget.vm.addNewAddress(
                  name: _name.text, 
                  phone: _phone.text, 
                  address: _addr.text, 
                  isDefault: _isDefault
                );
              }
              
              if (success && context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(isEdit ? "Cập nhật thành công!" : "Thêm mới thành công!"))
                );
              }
            }
          }, 
          child: Text(isEdit ? "Cập nhật" : "Xác nhận"),
        ),
      ],
    );
  }
}