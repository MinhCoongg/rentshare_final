import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentshare_app/models/address_model.dart';
import 'package:rentshare_app/viewmodels/address_viewmodel.dart';
import 'package:rentshare_app/views/addUpdateAddress/widget/formAddress.dart';

class AddressSelectionScreen extends StatefulWidget {
  @override
  State<AddressSelectionScreen> createState() => _AddressSelectionScreenState();
}

class _AddressSelectionScreenState extends State<AddressSelectionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AddressSelectionViewModel>().loadAddresses();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        title: const Text("Sổ địa chỉ", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [TextButton(onPressed: () {}, child: const Text("+ Thêm địa chỉ"))],
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<AddressSelectionViewModel>(
              builder: (context, vm, child) {
                return ListView.builder(
                  itemCount: vm.addresses.length,
                  itemBuilder: (context, index) {
                    final addr = vm.addresses[index];
                    return _buildAddressCard(context, addr, vm);
                  },
                );
              },
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4A25AA), minimumSize: const Size(double.infinity, 50)),
              onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AddAddressDialog(
                  vm: Provider.of<AddressSelectionViewModel>(context, listen: false),
                ),
              );
            },
              child: const Text("+ Thêm địa chỉ mới"),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildAddressCard(BuildContext context, AddressModel addr, AddressSelectionViewModel vm) {
    bool isSelected = vm.selectedAddress?.id == addr.id;
    return  Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? const Color(0xFF4A25AA) : Colors.transparent, 
          width: 2,
        ),
      ),
      child: InkWell( 
        onTap: () => vm.selectAddress(addr),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (addr.isDefault) 
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), 
                      decoration: BoxDecoration(color: Colors.purple.shade50, borderRadius: BorderRadius.circular(4)), 
                      child: Text("Mặc định", style: TextStyle(color: Colors.purple.shade700, fontSize: 10))
                    ),
                  const Spacer(),
                  Radio(
                    value: addr, 
                    groupValue: vm.selectedAddress, 
                    onChanged: (val) => vm.selectAddress(val!),
                  ),
                ],
              ),
              Text(addr.receiverName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 4),
              Text(addr.receiverPhone),
              const SizedBox(height: 4),
              Text(addr.fullAddress, style: TextStyle(color: Colors.grey[600])),

              const Divider(height: 24),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text("Sửa"),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AddAddressDialog(
                          vm: vm,
                          editAddress: addr,
                        ),
                      );
                    },
                  ),
                  
                  // --- NÚT XÓA ---
                  TextButton.icon(
                    icon: const Icon(Icons.delete, size: 16, color: Colors.red),
                    label: const Text("Xóa", style: TextStyle(color: Colors.red)),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text("Xác nhận xóa"),
                          content: const Text("Bạn có chắc muốn xóa địa chỉ này không?"),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Hủy")),
                            TextButton(
                              onPressed: () async {
                                Navigator.pop(ctx); // Đóng dialog trước
                                bool success = await vm.deleteAddress(addr.id!);
                                if (success && context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Đã xóa địa chỉ thành công!"), backgroundColor: Colors.green),
                                  );
                                }
                              },
                              child: const Text("Xóa", style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}