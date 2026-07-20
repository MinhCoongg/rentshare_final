import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentshare_app/viewmodels/checkout_viewmodel.dart';
import 'package:rentshare_app/viewmodels/voucher_viewmodel.dart';
import 'package:rentshare_app/views/checkout_page/widget/voucher.dart';

class VoucherSectionWidget extends StatelessWidget {
  final CheckoutViewModel checkoutVM;

  const VoucherSectionWidget({super.key, required this.checkoutVM});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Mã giảm giá", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87)),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () {
            showModalBottomSheet(
              context: context,
              backgroundColor: Colors.white,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
              builder: (_) => ChangeNotifierProvider.value(
                value: context.read<VoucherViewModel>(),
                child: VoucherSelectionSheet(checkoutVM: checkoutVM),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              children: [
                const Icon(Icons.confirmation_number_outlined, color: Color(0xFF4F46E5), size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    checkoutVM.appliedVoucher == null 
                        ? "Chọn hoặc nhập mã giảm giá" 
                        : "Đã chọn: ${checkoutVM.appliedVoucher!.code}",
                    style: TextStyle(
                      color: checkoutVM.appliedVoucher == null ? Colors.grey : Colors.black,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
                if (checkoutVM.appliedVoucher != null)
                   const Icon(Icons.check_circle, color: Colors.green, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }
}