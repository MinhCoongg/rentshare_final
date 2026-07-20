import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentshare_app/utils/format_utils.dart';
import 'package:rentshare_app/viewmodels/checkout_viewmodel.dart';
import 'package:rentshare_app/viewmodels/voucher_viewmodel.dart';

class VoucherSelectionSheet extends StatelessWidget {
  final CheckoutViewModel checkoutVM;
  const VoucherSelectionSheet({super.key, required this.checkoutVM});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VoucherViewModel>().loadVouchers();
    });

    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text("Chọn Voucher", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Expanded(
            child: Consumer<VoucherViewModel>(
              builder: (context, vVM, _) {
                if (vVM.isLoading) return const Center(child: CircularProgressIndicator());
                if (vVM.vouchers.isEmpty) return const Center(child: Text("Hiện không có voucher khả dụng"));
                return ListView.builder(
                  itemCount: vVM.vouchers.length,
                  itemBuilder: (ctx, i) {
                    final v = vVM.vouchers[i];
                    double totalOrder = checkoutVM.calculateTotalRentalFee(checkoutVM.cartitem);
                    bool isAvailable = totalOrder >= v.minOrderValue;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      color: isAvailable ? Colors.white : Colors.grey.shade200, 
                      child: ListTile(
                        title: Text(v.title, style: TextStyle(
                            fontWeight: FontWeight.bold, 
                            color: isAvailable ? Colors.black : Colors.grey
                        )),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Đơn tối thiểu: ${FormatUtils.formatMoney(v.minOrderValue)}đ"),
                            if (!isAvailable) 
                              Text("Chưa đủ điều kiện", style: TextStyle(color: Colors.red, fontSize: 11)),
                          ],
                        ),

                        onTap: isAvailable ? () {
                          checkoutVM.applyVoucher(v);
                          Navigator.pop(context);
                        } : null, 
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}