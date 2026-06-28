import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentshare_app/utils/format_utils.dart'; 
import 'package:rentshare_app/viewmodels/checkout_viewmodel.dart';
import 'package:rentshare_app/viewmodels/rental_cart_viewmodel.dart';

class PaymentPage extends StatelessWidget {
  const PaymentPage({super.key});

  @override
  Widget build(BuildContext context) {
    final checkoutVM = context.watch<CheckoutViewModel>();
    final cartProvider = context.watch<RentalCartProvider>();
    
    double rentalFeeTotal = checkoutVM.calculateTotalRentalFee(cartProvider.items);
    
    double depositTotal = cartProvider.totalDeposit; // Tổng tiền cọc của toàn bộ giỏ hàng
    double shippingFee = checkoutVM.getShippingFee(); // Phí ship (30k nếu chọn Shipping, 0đ nếu Pickup)
    double totalOrderAmount = rentalFeeTotal + depositTotal + shippingFee;

    bool isEnoughBalance = checkoutVM.walletBalance >= totalOrderAmount;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          "Xác nhận thanh toán", 
          style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold)
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: const BackButton(color: Colors.black),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 💳 KHỐI 1: PHƯƠNG THỨC THANH TOÁN (Ví nội bộ RentShare)
                  const Text("Phương thức thanh toán", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF4F46E5), width: 1.5),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.account_balance_wallet_rounded, color: Color(0xFF4F46E5), size: 26),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Ví điện tử RentShare", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              const SizedBox(height: 4),
                              Text(
                                "Số dư: ${FormatUtils.formatMoney(checkoutVM.walletBalance)}đ",
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.check_circle, color: Color(0xFF4F46E5), size: 18),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  const Text("Chi tiết thanh toán", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
      
                        _buildPriceRow("Tiền thuê (${checkoutVM.rentalDays} ngày)", rentalFeeTotal),
                        const SizedBox(height: 12),
                        _buildPriceRow("Tiền cọc (hoàn lại)", depositTotal),
                        const SizedBox(height: 12),
                        _buildPriceRow("Phí vận chuyển", shippingFee),
                        const Divider(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Tổng cộng", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            Text(
                              "${FormatUtils.formatMoney(totalOrderAmount)}đ",
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Color(0xFF4F46E5)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  if (!isEnoughBalance)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: Colors.red, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "Số dư ví RentShare không đủ để thanh toán. Vui lòng nạp thêm!", 
                                style: TextStyle(color: Colors.red.shade700, fontSize: 12, fontWeight: FontWeight.w500)
                              )
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFEEEEEE), width: 0.5)),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isEnoughBalance ? const Color(0xFF4F46E5) : Colors.grey[300],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                onPressed: (isEnoughBalance && !checkoutVM.isLoading) 
                  ? () async {
                      bool success = await checkoutVM.createOrder(cartProvider.items);  
                      if (success && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Gửi yêu cầu thuê thành công! Vui lòng chờ chủ shop duyệt đơn"), 
                            backgroundColor: Color(0xff1B8A4B),
                            duration: Duration(seconds: 3),
                          )
                        );
                        cartProvider.clearCart(); 
                        Navigator.pushNamedAndRemoveUntil(context, '/my-order', (route) => false);
                      } else if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Đặt đơn thất bại! Vui lòng kiểm tra lại lịch hoặc số dư ví"), 
                            backgroundColor: Colors.red,
                          )
                        );
                      }
                    }
                  : null,
                child: checkoutVM.isLoading 
                  ? const SizedBox(
                      width: 20, 
                      height: 20, 
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : Text(
                      "Xác nhận thanh toán", 
                      style: TextStyle(
                        color: isEnoughBalance ? Colors.white : Colors.grey[500],  
                        fontWeight: FontWeight.bold, 
                        fontSize: 14,
                      ),
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildPriceRow(String label, double amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.w500)),
        Text("${FormatUtils.formatMoney(amount)}đ", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
      ],
    );
  }
}