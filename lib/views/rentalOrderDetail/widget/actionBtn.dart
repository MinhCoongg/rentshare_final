import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentshare_app/utils/dialog_confirm.dart';
import 'package:rentshare_app/viewmodels/rental_order_viewmodel.dart';
import 'package:rentshare_app/views/rentalOrderDetail/widget/proofProduct.dart';

class RenterActionButton extends StatelessWidget {
  final dynamic order;
  final Color primaryColor;

  const RenterActionButton({
    super.key,
    required this.order,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    if (order.status == 'Pending') {
      return ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE07A5F),
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: 0),
        onPressed: () async {
          final bool isConfirm = await DifferentShopDialog.show(
            context: context,
            title: "Xác nhận hủy đơn",
            content: "Bạn có chắc chắn muốn hủy đơn thuê này không?",
            actionButtonText: "Hủy đơn ngay",
          );
          if (isConfirm && context.mounted) {
            final result = await context.read<RentalOrderViewModel>().cancelOrder(order.id);
            if (context.mounted && result['success'] == true) {
              context.read<RentalOrderViewModel>().loadOrderDetailFull(order.id);
            }
          }
        },
        icon: const Icon(Icons.cancel_presentation_outlined, size: 16, color: Colors.white),
        label: const Text("Hủy đơn thuê", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      );
    }

    if (order.status == 'Delivered') {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xff1B8A4B),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
        ),
        onPressed: () {
          Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReturnOrderScreen(orderId: order.id),
          ),
        ).then((value) async { 
          if (value == true) {
            await Future.delayed(const Duration(milliseconds: 300)); 
            if (context.mounted) {
              context.read<RentalOrderViewModel>().loadOrderDetailFull(order.id);
            }
          }
        });
        },
        child: const Text("Tôi đã trả hàng", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      );
    }

    if (order.status == 'Returned') {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[400],
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: 0),
        onPressed: null,
        child: const Text("Chờ shop xác nhận nhận", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      );
    }

    return const SizedBox.shrink();
  }
}