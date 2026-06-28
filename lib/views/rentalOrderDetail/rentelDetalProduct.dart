import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentshare_app/utils/format_utils.dart';
import 'package:rentshare_app/viewmodels/rental_order_viewmodel.dart';
import 'package:rentshare_app/views/rentalOrderDetail/widget/actionBtn.dart';
import 'package:rentshare_app/views/rentalOrderDetail/widget/info_text_row.dart';
import 'package:rentshare_app/views/rentalOrderDetail/widget/section_container.dart';
import 'package:rentshare_app/views/rentalOrderDetail/widget/time_line_step.dart';

class OrderDetailScreen extends StatefulWidget {
  final int orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RentalOrderViewModel>().loadOrderDetailFull(widget.orderId);
    });
  }


  String _parseAndFormat(String? value) {
    final double amount = double.tryParse(value ?? '0') ?? 0.0;
    return "${FormatUtils.formatMoney(amount)}đ";
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF00B4D8); 
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Chi tiết đơn thuê",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.help_outline, size: 16, color: primaryColor),
            label: const Text("Hỗ trợ", style: TextStyle(color: primaryColor, fontSize: 13, fontWeight: FontWeight.bold)),
          )
        ],
      ),
      body: Consumer<RentalOrderViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator(color: primaryColor));
          }

          if (viewModel.errorMessage.isNotEmpty) {
            return Center(
              child: Text(viewModel.errorMessage, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            );
          }

          final order = viewModel.currentOrder;
          if (order == null) return const Center(child: Text("Không có dữ liệu đơn thuê này!"));

         
          String statusText = order.status; 
          Color statusColor = Colors.black87;

          if (order.status == 'Pending') { statusText = "Chờ duyệt"; statusColor = Colors.orange[700]!; }
          else if (order.status == 'Approved') { statusText = "Đã duyệt"; statusColor = Colors.blue; }
          else if (order.status == 'Shipping') { statusText = "Đang giao"; statusColor = Colors.teal; }
          else if (order.status == 'Delivered') { statusText = "Đang thuê"; statusColor = primaryColor; }
          else if (order.status == 'Returned') { statusText = "Chờ trả hàng"; statusColor = Colors.purple; } 
          else if (order.status == 'Completed') { statusText = "Đã hoàn tất"; statusColor = Colors.green; }
          else if (order.status == 'Cancelled') { statusText = "Đã hủy"; statusColor = Colors.red; }
          return Stack(
            children: [
              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF7ED),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFFEDD5)),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: const Color(0xFFFFEDD5),
                            radius: 22,
                            child: Icon(Icons.hourglass_empty_rounded, color: Colors.orange[800], size: 24),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Đơn hàng đang $statusText",
                                  style: TextStyle(color: Colors.orange[900], fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  order.status == 'Pending'
                                      ? "Chủ shop sẽ xem xét và duyệt đơn trong 24 – 48 giờ. Khi được duyệt, chúng tôi sẽ thông báo cho bạn."
                                      : "Đơn hàng đang được vận hành đúng quy trình trên hệ thống RentShare.",
                                  style: TextStyle(color: Colors.orange[800], fontSize: 12, height: 1.3),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),

                    SectionContainer(
                      title: "Thông tin đơn hàng",
                      icon: Icons.assignment_outlined,
                      primaryColor: primaryColor,
                      child: Column(
                        children: [
                          InfoTextRow(label: "Mã đơn hàng", value: order.orderCode, isBold: true),
                          InfoTextRow(label: "Ngày đặt", value: order.orderDate),
                          InfoTextRow(label: "Trạng thái", value: statusText, valueColor: statusColor, isBold: true),
                          InfoTextRow(label: "Phương thức giao", value: order.shippingMethod == 'SelfPickUp' ? 'Tự đến lấy đồ' : 'Giao hàng tận nơi'),
                          InfoTextRow(label: "Thanh toán", value: "Ví RentShare"),
                          const Divider(height: 20, thickness: 0.5),
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 14,
                                backgroundColor: Colors.grey[200],
                                backgroundImage: order.ownerAvatar.isNotEmpty ? NetworkImage(order.ownerAvatar) : null,
                                child: order.ownerAvatar.isEmpty ? const Icon(Icons.person, size: 16) : null,
                              ),
                              const SizedBox(width: 8),
                              Text(order.ownerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              const Spacer(),
                              const Icon(Icons.chevron_right, color: Colors.grey, size: 20)
                            ],
                          )
                        ],
                      ),
                    ),

                    SectionContainer(
                      title: "Danh sách sản phẩm",
                      icon: Icons.shopping_bag_outlined,
                      primaryColor: primaryColor,
                      child: Column(
                        children: order.items.map((item) {
                          double price = double.tryParse(item.pricePerDay) ?? 0.0;
                          double itemTotal = price * order.rentalDays * item.quantity;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    item.image,
                                    width: 70,
                                    height: 70,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Container(
                                      width: 70, height: 70, color: Colors.grey[200],
                                      child: const Icon(Icons.image, color: Colors.grey, size: 20),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.title,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, height: 1.3),
                                      ),
                                      const SizedBox(height: 4),
                                      Text("x ${item.quantity}", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(Icons.calendar_month_outlined, color: Colors.grey, size: 12),
                                          const SizedBox(width: 4),
                                          Expanded( 
                                            child: Text(
                                              "${order.startDateFormatted} - ${order.endDateFormatted} (${order.rentalDays} ngày)",
                                              style: TextStyle(color: Colors.grey[500], fontSize: 11),
                                              overflow: TextOverflow.ellipsis, 
                                              maxLines: 1, 
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Text("${FormatUtils.formatMoney(itemTotal)}đ", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    SectionContainer(
                      title: "Thông tin nhận sản phẩm",
                      icon: Icons.local_shipping_outlined,
                      primaryColor: primaryColor,
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("${order.receiverName} - ${order.receiverPhone}", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 4),
                                Text(order.fullAddress, style: TextStyle(color: Colors.grey[600], fontSize: 12, height: 1.3)),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: Colors.grey)
                        ],
                      ),
                    ),

                    SectionContainer(
                      title: "Chi tiết thanh toán",
                      icon: Icons.credit_card_outlined,
                      primaryColor: primaryColor,
                      child: Column(
                        children: [
                          InfoTextRow(label: "Tiền thuê (${order.rentalDays} ngày)", value: _parseAndFormat(order.rentalFee)),
                          InfoTextRow(label: "Tiền cọc giữ đồ", value: _parseAndFormat(order.depositFee)),
                          InfoTextRow(label: "Phí ship vận chuyển", value: _parseAndFormat(order.shippingFee)),
                          const Divider(height: 24, thickness: 0.8, color: Color(0xFFE5E7EB)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                order.status == 'Pending' ? "Tổng chi phí dự kiến" : "Tổng tiền thanh toán",
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              Text(
                                _parseAndFormat(order.totalAmount),
                                style: const TextStyle(color: Color(0xFFE07A5F), fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
            
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(color: const Color(0xFFE0F2FE), borderRadius: BorderRadius.circular(8)),
                            child: Row(
                              children: [
                                const Icon(Icons.verified_user_outlined, color: Color(0xFF0369A1), size: 16),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    order.status == 'Pending'
                                        ? "Hệ thống chỉ tạm thời đóng băng tiền cọc ${_parseAndFormat(order.depositFee)} để giữ chân đơn. Tiền thuê và ship thực tế sẽ cấn trừ giải ngân khi hoàn tất trả đồ."
                                        : "Giao dịch đã được giải ngân cấn trừ minh bạch trên sổ cái hệ thống RentShare.",
                                    style: const TextStyle(color: Color(0xFF0369A1), fontSize: 11, height: 1.3),
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    SectionContainer(
                      title: "Lịch sử đơn hàng",
                      icon: Icons.history,
                      primaryColor: primaryColor,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // 1. Đặt đơn
                            Expanded(
                              child: TimelineStep(
                                label: "Đặt đơn",
                                isCompleted: true,
                              ),
                            ),
                            // 2. Chờ duyệt
                            Expanded(
                              child: TimelineStep(
                                label: "Chờ duyệt",
                                isCompleted: ['Approved', 'Shipping', 'Delivered', 'Returned', 'Completed'].contains(order.status),
                              ),
                            ),
                            // 3. Đang giao
                            Expanded(
                              child: TimelineStep(
                                label: "Đang giao",
                                isCompleted: ['Shipping', 'Delivered', 'Returned', 'Completed'].contains(order.status),
                              ),
                            ),
                            // 4. Đã thuê
                            Expanded(
                              child: TimelineStep(
                                label: "Đã thuê",
                                isCompleted: ['Delivered', 'Returned', 'Completed'].contains(order.status),
                              ),
                            ),
                            // 5. Chờ trả
                            Expanded(
                              child: TimelineStep(
                                label: "Chờ trả",
                                isCompleted: ['Returned', 'Completed'].contains(order.status),
                              ),
                            ),
                            // 6. Hoàn tất
                            Expanded(
                              child: TimelineStep(
                                label: "Hoàn tất",
                                isCompleted: order.status == 'Completed',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),

        
              Positioned(
                left: 0, right: 0, bottom: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, -4))],
                    border: const Border(top: BorderSide(color: Color(0xFFE5E7EB), width: 0.5)),
                  ),
                  child: SafeArea(
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              side: BorderSide(color: Colors.grey[300]!),
                            ),
                            onPressed: () {}, // Logic chat
                            child: const Text("Liên hệ shop", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: RenterActionButton(order : order, primaryColor: primaryColor),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}