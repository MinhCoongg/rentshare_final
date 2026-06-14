import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentshare_app/viewmodels/rental_cart_viewmodel.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  String deliveryMethod = 'Shipping'; 

  @override
  Widget build(BuildContext context) {

    final cartProvider = context.watch<RentalCartProvider>();


    int fixedRentalDays = 3; 



    double calculatedRentalFee = cartProvider.totalRentalFeePerDay * fixedRentalDays; 
    

    double depositFee = cartProvider.totalDeposit; 
    
    double shippingFee = (deliveryMethod == 'Shipping') ? 30000.0 : 0.0; 
    
  
    double totalAmount = calculatedRentalFee + depositFee + shippingFee;

   
    final formatter = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    String formatMoney(double value) => "${value.toStringAsFixed(0).replaceAllMapped(formatter, (Match m) => '${m[1]}.')}đ";


    String rentalFeeText = formatMoney(calculatedRentalFee);
    String depositFeeText = formatMoney(depositFee);
    String shippingFeeText = formatMoney(shippingFee);
    String totalAmountText = formatMoney(totalAmount);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          "Thời gian thuê & Hình thức nhận hàng",
          style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 16),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          
            const Text(
              "Thời gian thuê",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_month_rounded, color: Color(0xFF6366F1), size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Ngày bắt đầu\n12/05/2024",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, height: 1.3),
                        ),
                        Icon(Icons.arrow_forward_rounded, color: Colors.grey[400], size: 16),
                        const Text(
                          "Ngày kết thúc\n15/05/2024",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, height: 1.3),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEF2FF),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            "3 ngày",
                            style: TextStyle(color: Color(0xFF6366F1), fontWeight: FontWeight.bold, fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

        
            const Text(
              "Hình thức nhận hàng",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black),
            ),
            const SizedBox(height: 12),
            
    
            _buildDeliveryOption(
              value: 'Shipping',
              title: "Giao hàng tận nơi (có phí)",
              subtitle: "Nhập địa chỉ giao hàng của bạn. Shop sẽ giao tận nơi.",
              icon: Icons.local_shipping_rounded,
            ),
            const SizedBox(height: 12),
            

            _buildDeliveryOption(
              value: 'Pickup',
              title: "Đến shop lấy hàng (miễn phí)",
              subtitle: "Bạn đến trực tiếp địa chỉ shop nhận hàng, không tốn phí ship.",
              icon: Icons.storefront_rounded,
            ),
            const SizedBox(height: 24),

if (deliveryMethod == 'Shipping') ...[
  const Padding(
    padding: EdgeInsets.only(bottom: 10),
    child: Text(
      "Địa chỉ nhận hàng",
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14), // 🎯 ĐƯA STYLE VÀO TRONG TEXT NÀY NÍ CÔNG!
    ),
  ),
  _buildInfoContainer(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Text("Nguyễn Minh Công", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            SizedBox(width: 8),
            Text("(Mặc định)", style: TextStyle(color: Colors.grey, fontSize: 11)),
          ],
        ),
        const SizedBox(height: 6),
        const Text("0912345678", style: TextStyle(color: Colors.black87, fontSize: 13)),
        const SizedBox(height: 4),
        Text("123 Nguyễn Văn Cừ, P. Bến Thành, Quận 1, TP. Hồ Chí Minh", style: TextStyle(color: Colors.grey[600], fontSize: 12, height: 1.3)),
      ],
    ),
  ),
] else ...[
  const Padding(
    padding: EdgeInsets.only(bottom: 10),
    child: Text(
      "Địa chỉ shop",
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14), 
    ),
  ),
  _buildInfoContainer(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Outdoor Gear (Shop của Nguyễn Văn A)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(height: 6),
        Text("123 Nguyễn Văn Cừ, P. Bến Thành, Quận 1, TP. Hồ Chí Minh", style: TextStyle(color: Colors.grey[600], fontSize: 12, height: 1.3)),
        const SizedBox(height: 6),
        const Text("Giờ làm việc: 08:00 - 18:00", style: TextStyle(color: Colors.orange, fontSize: 11, fontWeight: FontWeight.bold)),
      ],
    ),
  ),
],
            const SizedBox(height: 24),

           
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Tóm tắt đơn thuê", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 14),
                  _buildPriceRow("Tổng tiền thuê (ước tính)", rentalFeeText),
                  const SizedBox(height: 10),
                  _buildPriceRow("Tiền cọc (hoàn lại)", depositFeeText),
                  const SizedBox(height: 10),
                  _buildPriceRow("Phí giao hàng", shippingFeeText),
                  const Divider(height: 24, thickness: 0.5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Tổng cộng", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      Text(
                        totalAmountText,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF6366F1)), // Tự động co giãn theo tiền thật trong giỏ
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

           
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1), 
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                onPressed: () {
                 
                },
                child: const Text(
                  "Tiếp tục",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryOption({
    required String value,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    bool isSelected = deliveryMethod == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          deliveryMethod = value; 
        });
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF6366F1) : Colors.grey[200]!,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: isSelected ? const Color(0xFF6366F1) : Colors.grey[400], size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(color: Colors.grey[500], fontSize: 12, height: 1.3)),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
              color: isSelected ? const Color(0xFF6366F1) : Colors.grey[300],
              size: 18,
            )
          ],
        ),
      ),
    );
  }

  Widget _buildInfoContainer({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: child,
    );
  }

  Widget _buildPriceRow(String label, String price) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
        Text(price, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13, color: Colors.black87)),
      ],
    );
  }
}