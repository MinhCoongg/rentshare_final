import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentshare_app/utils/dialog_confirm.dart';
import 'package:rentshare_app/utils/format_utils.dart';
import 'package:rentshare_app/viewmodels/rental_order_viewmodel.dart'; 


class OwnerRentalManagementScreen extends StatefulWidget {
  final int rentalRequestId;

  const OwnerRentalManagementScreen({super.key, required this.rentalRequestId});

  @override
  State<OwnerRentalManagementScreen> createState() => _OwnerRentalManagementScreenState();
}

class _OwnerRentalManagementScreenState extends State<OwnerRentalManagementScreen> {
  final TextEditingController _reasonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Tự động load chi tiết đơn hàng cho chủ shop khi vừa mở trang
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RentalOrderViewModel>().getOrderDetailById(widget.rentalRequestId);
    });
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  String _format(String? value) {
    final double amount = double.tryParse(value ?? '0') ?? 0.0;
    return "${FormatUtils.formatMoney(amount)}đ";
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF00B4D8); // Màu xanh RentShare xập xình

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
          "Chi tiết đơn hàng",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: Consumer<RentalOrderViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator(color: primaryColor));
          }

          final order = viewModel.currentOrder; // Giả định trường dữ liệu đơn hiện tại trong ViewModel
          if (order == null) return const Center(child: Text("Không tìm thấy dữ liệu đơn thuê!"));

          return Stack(
            children: [
              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🔔 1. Tag trạng thái đơn
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF7ED),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        order.status == 'Pending' ? " Chờ duyệt" : order.status,
                        style: TextStyle(color: Colors.orange[800], fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text("Mã đơn: ${order.orderCode}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    Text("Đặt lúc: ${order.orderDate}", style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                    const SizedBox(height: 20),

                    // 👤 2. Khối: Thông tin khách hàng đi thuê
                    _buildCardWrapper(
                      title: "Thông tin khách hàng",
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: Colors.grey[200],
                            backgroundImage: order.ownerAvatar.isNotEmpty ? NetworkImage(order.ownerAvatar) : null,
                            child: order.ownerAvatar.isEmpty ? const Icon(Icons.person) : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(order.receiverName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                const SizedBox(height: 2),
                                Text(order.receiverPhone, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                Text(order.fullAddress, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                                const SizedBox(height: 4),
                                Text(order.fullAddress, style: TextStyle(color: Colors.grey[600], fontSize: 12, height: 1.3)),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.chat_bubble_outline, color: primaryColor, size: 20),
                            onPressed: () {}, // Mở hộp chat bốc sang với khách
                          )
                        ],
                      ),
                    ),

                    // 📅 3. Khối: Chi tiết lịch trình & hình thức nhận
                    _buildCardWrapper(
                      title: "Thông tin đơn thuê",
                      child: Column(
                        children: [
                          _buildDetailRow(Icons.calendar_month_outlined, "Ngày thuê", "${order.startDateFormatted} - ${order.endDateFormatted}", trailing: "${order.rentalDays} ngày"),
                          const Divider(height: 20, thickness: 0.5),
                          _buildDetailRow(Icons.local_shipping_outlined, "Hình thức nhận hàng", order.shippingMethod == 'SelfPickUp' ? 'Tự đến lấy đồ' : 'Giao hàng tận nơi'),
                          const Divider(height: 20, thickness: 0.5),
                          _buildDetailRow(Icons.location_on_outlined, "Địa chỉ giao hàng", order.fullAddress),
                          const Divider(height: 20, thickness: 0.5),
                          _buildDetailRow(Icons.edit_note_outlined, "Ghi chú của khách", order.notes ?? 'Không có ghi chú nào.'),
                        ],
                      ),
                    ),

                    // ⛺ 4. Khối: Danh sách sản phẩm chủ shop cho thuê (Vòng lặp mảng items)
                    _buildCardWrapper(
                      title: "Sản phẩm thuê",
                      child: Column(
                        children: [
                          ...order.items.map<Widget>((item) => Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: Image.network(item.image, width: 60, height: 60, fit: BoxFit.cover),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                      Text("${_format(item.pricePerDay)} / ngày", style: TextStyle(color: Colors.grey[500], fontSize: 11)),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text("x${item.quantity}", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                    Text("${order.rentalDays} ngày", style: TextStyle(color: Colors.grey[500], fontSize: 11)),
                                    Text(_format((double.parse(item.pricePerDay) * order.rentalDays * item.quantity).toString()), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                  ],
                                )
                              ],
                            ),
                          )).toList(),
                          const Divider(height: 24, thickness: 0.8),
                          _buildAmountRow("Tạm tính (tiền thuê)", _format(order.rentalFee)),
                          _buildAmountRow("Phí giao hàng", _format(order.shippingFee)),
                          _buildAmountRow("Tiền cọc (đã đóng băng ví)", _format(order.depositFee)),
                          const Divider(height: 24, thickness: 0.8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Tổng thanh toán", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              Text(_format(order.totalAmount), style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 18)),
                            ],
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),

              // 🕹️ 5. Thanh Điều Khiển Duyệt/Từ Chối ghim dưới đáy màn hình
              Positioned(
                left: 0, right: 0, bottom: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  color: Colors.white,
                  child: SafeArea(
                    child: Row(
                      children: [
                        // ❌ Nút Từ chối đơn: Kích hoạt gọi hộp thoại Dialog của ní Công
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: order.status == 'Pending' ? () => _handleRejectOrder(context, order) : null,
                            child: const Text("✕ Từ chối đơn", style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        //  Nút Duyệt đơn: Chuyển màu xanh thương hiệu RentShare
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: order.status == 'Pending' ? () => _handleApproveOrder(context, order) : null,
                            child: const Text("✓ Duyệt đơn", style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }

  // =========================================================================
  // 🔴 LOGIC XỬ LÝ KHI BẤM TỪ CHỐI: GỌI DIALOG XỊN CỦA NÍ CÔNG VÀO ĐÂY
  // =========================================================================
  void _handleRejectOrder(BuildContext context, dynamic order) async {
    // Gọi hàm động nổ Dialog nhập lý do từ chối y xì thiết kế màn hình 3
    final bool isConfirm = await DifferentShopDialog.show(
      context: context,
      title: "Từ chối đơn hàng",
      content: "Khi từ chối đơn, số tiền cọc ${_format(order.depositFee)} sẽ được hoàn lại vào ví RentShare của khách hàng.",
      actionButtonText: "Xác nhận từ chối",
    );

    if (isConfirm && mounted) {
      // Gọi lên ViewModel kích hoạt hàm rejectRequest bắn xuống Node.js hoàn tiền
      final result = await context.read<RentalOrderViewModel>().rejectRequest(
            rentalRequestId: order.id,
            cancelReason: "Chủ shop từ chối vì hết mặt hàng lưu kho.",
          );

      if (mounted && result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đã từ chối đơn hàng và hoàn cọc cho khách!")));
        Navigator.pop(context); // Quay về trang danh sách quản lý
      }
    }
  }

  // =========================================================================
  //  LOGIC XỬ LÝ KHI BẤM DUYỆT ĐƠN HÀNG
  // =========================================================================
  void _handleApproveOrder(BuildContext context, dynamic order) async {
    final result = await context.read<RentalOrderViewModel>().approveRequest(order.id);
    if (mounted && result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Duyệt đơn hàng thành công! Hóa đơn Invoice đã được khởi tạo.")));
      Navigator.pop(context);
    }
  }

  // Widget bộ khung bao bọc hoa văn thẻ trắng bo góc
  Widget _buildCardWrapper({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black54)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, {String? trailing}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey[500]),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 11)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black87)),
            ],
          ),
        ),
        if (trailing != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(4)),
            child: Text(trailing, style: const TextStyle(color: Colors.blue, fontSize: 11, fontWeight: FontWeight.bold)),
          )
      ],
    );
  }

  Widget _buildAmountRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}