import 'package:flutter/material.dart';
import 'package:rentshare_app/viewmodels/checkout_viewmodel.dart';
import 'package:rentshare_app/views/checkout_page/widget/formAddress.dart'; 

class SelectAddressSheet extends StatelessWidget {
  final CheckoutViewModel checkoutVM;
  const SelectAddressSheet({
    super.key, 
    required this.checkoutVM,
  });

  @override
  Widget build(BuildContext context) {
    final userAddresses = checkoutVM.userAddresses;

    return DraggableScrollableSheet(
      initialChildSize: 0.65, 
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                ),
              ),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Sổ địa chỉ nhận hàng của bạn",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey, size: 20),
                    onPressed: () => Navigator.pop(context),
                  )
                ],
              ),
              const SizedBox(height: 10),

              Expanded(
                child: userAddresses.isEmpty
                    ? Center(
                        child: Text(
                          "Sổ địa chỉ trống trơn!\nHãy tạo địa chỉ giao hàng để đặt đơn nhé.",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey[400], fontSize: 13, height: 1.4),
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        itemCount: userAddresses.length,
                        itemBuilder: (context, index) {
                          final addr = userAddresses[index];
                          final bool isSelected = checkoutVM.defaultAddress?.id == addr.id;

                          return InkWell(
                            onTap: () {
                              checkoutVM.selectAddressFromBook(addr);
                              Navigator.pop(context); 
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFF4F46E5).withOpacity(0.02) : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected ? const Color(0xFF4F46E5) : Colors.grey[200]!,
                                  width: isSelected ? 1.5 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                                    color: isSelected ? const Color(0xFF4F46E5) : Colors.grey,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(addr.receiverName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
                                            if (addr.isDefault == 1 || addr.isDefault == true) ...[
                                              const SizedBox(width: 6),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                                decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(4)),
                                                child: const Text("Mặc định", style: TextStyle(color: Colors.blue, fontSize: 9, fontWeight: FontWeight.bold)),
                                              )
                                            ]
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(addr.receiverPhone, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                        const SizedBox(height: 2),
                                        Text(addr.fullAddress, style: TextStyle(color: Colors.grey[600], fontSize: 12, height: 1.3)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),

              const SizedBox(height: 12),
              SafeArea(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 46),
                    side: BorderSide(color: Colors.blue[100]!),
                    backgroundColor: const Color(0xFFF5F9FF),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      // 🎯 2. ĐÃ SỬA KHÚC NÀY: Gọi đúng Dialog mới và truyền tham số checkoutVM khớp chuẩn 100%!
                      builder: (context) => AddAddressCheckoutDialog(checkoutVM: checkoutVM), 
                    ).then((_) {
                      // 🎯 3. ĐÃ SỬA LUỒNG TỰ ĐỘNG: Thêm xong tắt Dialog là bộ não tự đi chợ kéo dữ liệu mới đổ lên màn hình liền!
                      checkoutVM.fetchCheckoutData();
                    });
                  }, 
                  icon: const Icon(Icons.add, size: 16, color: Color(0xFF4F46E5)),
                  label: const Text(
                    "Thêm địa chỉ giao hàng mới", 
                    style: TextStyle(color: Color(0xFF4F46E5), fontWeight: FontWeight.bold, fontSize: 13)
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}