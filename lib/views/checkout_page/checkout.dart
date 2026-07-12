import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rentshare_app/viewmodels/checkout_viewmodel.dart';
import 'package:rentshare_app/viewmodels/rental_cart_viewmodel.dart'; 
import 'package:rentshare_app/views/checkout_page/widget/formAddress.dart';
import 'package:rentshare_app/views/checkout_page/widget/selected_addresses.dart';
import 'package:rentshare_app/views/payment/payment.dart';

class CheckoutPage extends StatefulWidget {
  final dynamic product; 
  final String shopAddress; 

  const CheckoutPage({
    super.key,
    required this.product,
    required this.shopAddress, 
  });

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cartProvider = Provider.of<RentalCartProvider>(context, listen: false);
      final checkoutVM = context.read<CheckoutViewModel>();
      
      checkoutVM.setCartItems(cartProvider.items);
      checkoutVM.fetchCheckoutData();
    });
  }

  Future<void> _pickDateRange(CheckoutViewModel vm) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      selectableDayPredicate: (
        DateTime day,
        DateTime? selectedStartDay,
        DateTime? selectedEndDay,
      ) {
       
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        if (day.isBefore(today)) {
          return false;
        }

        final formattedDay =
            "${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}";
        return !vm.bookedDates.contains(formattedDay);
      },
      
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF4F46E5)),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      vm.setDateRange(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final checkoutVM = context.watch<CheckoutViewModel>();
    if (checkoutVM.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Color(0xFF4F46E5))),
      );
    }

    bool isShipping = checkoutVM.deliveryMethod == 'Shipping';
    bool isPickup = checkoutVM.deliveryMethod == 'Pickup';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          "Thời gian thuê & hình thức nhận hàng",
          style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold),
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
                  const Text("Thời gian thuê", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87)),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () => _pickDateRange(checkoutVM),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_month_rounded, color: Color(0xFF4F46E5), size: 22),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  checkoutVM.selectedDateRange == null
                                      ? "Bấm để chọn ngày thuê"
                                      : "Ngày bắt đầu\n${DateFormat('dd/MM/yyyy').format(checkoutVM.selectedDateRange!.start)}",
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, height: 1.3),
                                ),
                                if (checkoutVM.selectedDateRange != null) ...[
                                  Icon(Icons.arrow_forward_rounded, color: Colors.grey[400], size: 16),
                                  Text(
                                    "Ngày kết thúc\n${DateFormat('dd/MM/yyyy').format(checkoutVM.selectedDateRange!.end)}",
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, height: 1.3),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(color: const Color(0xFFEEF2FF), borderRadius: BorderRadius.circular(20)),
                                    child: Text(
                                      "${checkoutVM.rentalDays} ngày",
                                      style: const TextStyle(color: Color(0xFF4F46E5), fontWeight: FontWeight.bold, fontSize: 11),
                                    ),
                                  ),
                                ]
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  const Text("Hình thức nhận hàng", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87)),
                  const SizedBox(height: 12),
                  
                  Container(
                    decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isShipping ? const Color(0xFF4F46E5) : const Color(0xFFE5E7EB), width: isShipping ? 1.5 : 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => checkoutVM.setDeliveryMethod('Shipping'),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              Icon(
                                isShipping ? Icons.check_circle : Icons.radio_button_off,
                                color: const Color(0xFF4F46E5),
                                size: 18,
                              ),
                              const SizedBox(width: 10),
                              const Text("Giao hàng tận nơi", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                              const SizedBox(width: 6),
                              Text("(có phí)", style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
                            ],
                          ),
                        ),
                      ),
                      if (isShipping) ...[
                        const Divider(height: 1),
                        Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  showModalBottomSheet(
                                    context: context,
                                    backgroundColor: Colors.white,
                                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                                    isScrollControlled: true,
                                    builder: (context) => SelectAddressSheet(
                                      checkoutVM: checkoutVM, 
                                    ),
                                  );
                                },
                                child: const Row(
                                  children: [
                                    Icon(Icons.reply, color: Color(0xFF4F46E5), size: 16),
                                    SizedBox(width: 8),
                                    Text("Nhập địa chỉ giao hàng", style: TextStyle(color: Color(0xFF4F46E5), fontWeight: FontWeight.w600, fontSize: 12)),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              
                              if (checkoutVM.defaultAddress != null) ...[
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.local_shipping_outlined, size: 18),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(checkoutVM.defaultAddress!.receiverName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                              const SizedBox(width: 8),
                                              const Text("(Mặc định)", style: TextStyle(color: Colors.grey, fontSize: 11)),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          Text(checkoutVM.defaultAddress!.receiverPhone, style: const TextStyle(fontSize: 12)),
                                          const SizedBox(height: 4),
                                          Text(checkoutVM.defaultAddress!.fullAddress, style: TextStyle(fontSize: 12, color: Colors.grey.shade700, height: 1.4)),
                                        ],
                                      ),
                                    ),
                                  ],
                                )
                              ],
                              const SizedBox(height: 16),
                              
                              GestureDetector(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AddAddressCheckoutDialog(checkoutVM: checkoutVM),
                                  ).then((_) {
                                    checkoutVM.fetchCheckoutData();
                                  });
                                },
                                child: const Text("+ Thêm địa chỉ mới", style: TextStyle(color: Color(0xFF4F46E5), fontWeight: FontWeight.w600, fontSize: 12)),
                              )
                            ],
                          ),
                        ),
                      ]
                    ],
                  ),
                ),

                  const SizedBox(height: 12),         
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isPickup ? const Color(0xFF4F46E5) : const Color(0xFFE5E7EB), width: isPickup ? 1.5 : 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () => checkoutVM.setDeliveryMethod('Pickup'),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              children: [
                                Icon(
                                  isPickup ? Icons.radio_button_checked : Icons.radio_button_off,
                                  color: const Color(0xFF4F46E5),
                                  size: 18,
                                ),
                                const SizedBox(width: 10),
                                const Text("Đến shop lấy hàng", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                const SizedBox(width: 6),
                                Text("(miễn phí)", style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
                              ],
                            ),
                          ),
                        ),
                        if (isPickup) ...[
                          const Divider(height: 1),
                          Padding(
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.storefront_outlined, size: 20),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text("Địa chỉ shop", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                                      const SizedBox(height: 8),
                                      Text(widget.product.ownerName ?? "Chủ shop Rentshare", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                      const SizedBox(height: 6),
                                      Text(
                                        "Liên hệ: ${widget.product.ownerPhone}",
                                        style: const TextStyle(fontSize: 12, color: Color(0xFF4F46E5), fontWeight: FontWeight.w500),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        widget.shopAddress,
                                        style: TextStyle(fontSize: 12, color: Colors.grey.shade700, height: 1.4),
                                      ),
                                      const SizedBox(height: 8),
                                      const Text("Giờ làm việc: 08:00 - 18:00", style: TextStyle(color: Colors.grey, fontSize: 11)),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ]
                      ],
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
                  backgroundColor: checkoutVM.selectedDateRange != null ? const Color(0xFF4F46E5) : Colors.grey[300],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                onPressed: checkoutVM.selectedDateRange == null
                    ? null
                    : () {
                        if (checkoutVM.deliveryMethod == "Shipping" &&
                            checkoutVM.defaultAddress == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Vui lòng chọn hoặc thêm địa chỉ giao hàng."),
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                          return;
                        }

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PaymentPage(),
                          ),
                        );
                      },
                child: const Text("Tiếp tục", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}