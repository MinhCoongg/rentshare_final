import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentshare_app/utils/dialog_confirm.dart';
import 'package:rentshare_app/utils/format_utils.dart';
import 'package:rentshare_app/viewmodels/rental_order_viewmodel.dart';
import 'package:rentshare_app/views/checkRentalProduct/report_back_owner.dart';
import 'package:rentshare_app/views/owner/widget/returned_product.dart';

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

 Color _getStatusColor(String status) {
  switch (status) {
    case 'Pending': return Colors.orange;
    case 'Approved': return Colors.teal;
    case 'Shipping': return Colors.blue;
    case 'Delivered': return Colors.green;
    case 'Returned': return const Color(0xFF7B1FA2);
    case 'Inspecting': return Colors.deepPurpleAccent;
    case 'Completed': return Colors.grey;
    default: return Colors.black54;
  }
}

  String _getStatusTextText(String status) {
    switch (status) {
      case 'Pending': return 'Chờ duyệt';
      case 'Approved': return 'Đã duyệt';
      case 'Shipping': return 'Đang giao';
      case 'Delivered': return 'Đang thuê';
      case 'Returned': return 'Chờ trả hàng';
      case 'Inspecting': return 'Đang nghiệm thu';
      case 'Completed': return 'Hoàn tất';
      default: return status;
    }
  }


  Widget _buildOrderStepper(String currentStatus) {
    List<String> statuses = ['Pending', 'Approved', 'Shipping', 'Delivered', 'Inspecting', 'Completed'];
    List<String> labels = ['Đã đặt', 'Đã duyệt', 'Đang giao', 'Đang thuê', 'Nghiệm thu', 'Hoàn tất'];
    
    int currentIndex = statuses.indexOf(currentStatus);
    if (currentStatus == 'Returned') currentIndex = 3; 

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(statuses.length, (index) {
          bool isPassed = index <= currentIndex;
          Color stepColor = isPassed ? const Color(0xFF00B4D8) : Colors.grey[300]!;
          return Expanded(
            child: Row(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 10,
                      backgroundColor: stepColor,
                      child: isPassed 
                          ? const Icon(Icons.check, size: 12, color: Colors.white)
                          : CircleAvatar(radius: 4, backgroundColor: Colors.grey[400]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      labels[index], 
                      style: TextStyle(
                        fontSize: 10, 
                        fontWeight: isPassed ? FontWeight.bold : FontWeight.normal, 
                        //color: index == 3 && currentStatus == 'Returned' ? Colors.orange : (isPassed ? Colors.black87 : Colors.grey)
                      )
                    ),
                  ],
                ),
                if (index < statuses.length - 1)
                  Expanded(
                    child: Container(height: 2, color: index < currentIndex ? const Color(0xFF00B4D8) : Colors.grey[300]),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTopContextBanner(String status, dynamic order) {
    if (status == 'Delivered') {
      int dynamicRemainingDays = 0;
      String deadlineText = "Chưa xác định";

      try {
        List<String> parts = (order.endDateFormatted ?? "").toString().split('/');
        if (parts.length == 3) {
          int day = int.parse(parts[0]);
          int month = int.parse(parts[1]);
          int year = int.parse(parts[2]);
          
          DateTime endDateTime = DateTime(year, month, day, 23, 59); 
          DateTime now = DateTime.now(); 
          dynamicRemainingDays = endDateTime.difference(now).inDays;
          deadlineText = "${order.endDateFormatted} - 23:59";
        }
      } catch (e) {
        debugPrint("Lỗi parse ngày tháng dynamic: $e");
      }

      String remainingText = dynamicRemainingDays > 0 
          ? "Còn $dynamicRemainingDays ngày" 
          : (dynamicRemainingDays == 0 ? "Hôm nay hạn trả!" : "Quá hạn ${dynamicRemainingDays.abs()} ngày ⚠️");

      return Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: const Color(0xFFF3E5F5), borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.access_time, color: Color(0xFF7B1FA2), size: 16),
                SizedBox(width: 6),
                Text("Thời gian thuê còn lại", style: TextStyle(color: Color(0xFF7B1FA2), fontSize: 11, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 4),
            Text(remainingText, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF7B1FA2))),
            Text("Trả trước: $deadlineText", style: const TextStyle(fontSize: 11, color: Colors.black54)),
          ],
        ),
      );
    }

    if (status == 'Returned') {
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: const Color(0xFFFFF4E5), borderRadius: BorderRadius.circular(12)),
        child: const Row(
          children: [
            Icon(Icons.info_outline, color: Colors.orange, size: 18),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Khách đã báo trả hàng", style: TextStyle(color: Color(0xFFB76E00), fontSize: 12, fontWeight: FontWeight.bold)),
                  Text("Vui lòng kiểm tra sản phẩm và xác nhận tình trạng.", style: TextStyle(color: Color(0xFFB76E00), fontSize: 11)),
                ],
              ),
            )
          ],
        ),
      );
    }

    if (order.status == 'Inspecting') {
      return Container(
        padding: const EdgeInsets.all(12),
        color: Colors.orange.withOpacity(0.1),
        child: Row(
          children: [
            const Icon(Icons.pending_actions, color: Colors.orange),
            const SizedBox(width: 8),
            const Text("Đang chờ khách xác nhận nghiệm thu", 
              style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildBottomActionBar(dynamic order, Color primaryColor) {
    if (order.status == 'Completed' || order.status == 'Cancelled') return const SizedBox.shrink();
    if (order.status == 'Pending') {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              onPressed: () => _handleRejectOrder(context, order),
              child: const Text("Từ chối đơn", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: primaryColor, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              onPressed: () => _handleApproveOrder(context, order),
              child: const Text("Duyệt đơn", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      );
    } 
    
    if (order.status == 'Shipping') {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(side: BorderSide(color: primaryColor), padding: const EdgeInsets.symmetric(vertical: 14)),
          onPressed: () {},
          child: Text("Đơn hàng đang trên đường đi giao...", style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
        ),
      );
    }
    if (order.status == 'Delivered') {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: primaryColor, width: 1.5),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: (){},
          child: Text("Khách đã trả hàng", style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 13)),
        ),
      );
    }

    if (order.status == 'Returned') {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6200EE), // Màu tím đậm sang chảnh y Figma
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: 0,
          ),
          onPressed: () async {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => NghiemThuProductScreen(order: order)),
            );
          },
          child: const Text("Xác nhận đã nhận hàng", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF00B4D8);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Chi tiết đơn hàng", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
      ),
      body: Consumer<RentalOrderViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator(color: primaryColor));
          }

          final order = viewModel.currentOrder;
          if (order == null) return const Center(child: Text("Không tìm thấy dữ liệu đơn thuê!"));

          Color currentStatusColor = _getStatusColor(order.status);

          return Stack(
            children: [
              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildOrderStepper(order.status),

                    _buildTopContextBanner(order.status, order),

                    ReturnVerificationSection(order: order),

                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(color: currentStatusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                      child: Text(
                        _getStatusTextText(order.status),
                        style: TextStyle(color: currentStatusColor, fontWeight: FontWeight.bold, fontSize: 11),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text("Mã đơn: ORD-${order.orderCode.replaceAll('#RS', '')}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text("Đặt lúc: ${order.orderDate}", style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                    const SizedBox(height: 16),

                    _buildCardWrapper(
                      title: "Thông tin khách hàng",
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: Colors.blueGrey[100],
                            child: const Icon(Icons.person, color: Colors.blueGrey, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(order.receiverName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                const SizedBox(height: 2),
                                Text(order.receiverPhone, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                const SizedBox(height: 2),
                                Text(order.fullAddress, style: TextStyle(color: Colors.grey[500], fontSize: 11, height: 1.3)),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.chat_bubble_outline, color: primaryColor, size: 18),
                            onPressed: () {},
                          )
                        ],
                      ),
                    ),

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
                                  child: item.image != null && item.image.isNotEmpty 
                                      ? Image.network(item.image, width: 50, height: 50, fit: BoxFit.cover)
                                      : Container(width: 50, height: 50, color: Colors.grey[200], child: const Icon(Icons.image, size: 20)),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                      Text("${_format(item.pricePerDay)} / ngày", style: TextStyle(color: Colors.grey[500], fontSize: 11)),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text("x${item.quantity}", style: TextStyle(color: Colors.grey[600], fontSize: 11)),
                                    Text(_format((double.parse(item.pricePerDay) * order.rentalDays * item.quantity).toString()), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                  ],
                                )
                              ],
                            ),
                          )),
                          const Divider(height: 20, thickness: 0.8),
                          _buildAmountRow("Tạm tính (tiền thuê)", _format(order.rentalFee)),
                          _buildAmountRow("Phí giao hàng", _format(order.shippingFee)),
                          _buildAmountRow("Tiền cọc (đã đóng băng ví)", _format(order.depositFee)),
                          const Divider(height: 20, thickness: 0.8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Tổng thanh toán", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              Text(_format(order.totalAmount), style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 16)),
                            ],
                          )
                        ],
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
                  decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, -2))]),
                  child: SafeArea(
                    child: _buildBottomActionBar(order, primaryColor),
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }

  
  

  void _handleRejectOrder(BuildContext context, dynamic order) async {
    final bool isConfirm = await DifferentShopDialog.show(
      context: context,
      title: "Từ chối đơn hàng",
      content: "Khi từ chối đơn, số tiền cọc ${_format(order.depositFee)} sẽ được hoàn lại vào ví RentShare của khách hàng.",
      actionButtonText: "Xác nhận từ chối",
    );

    if (isConfirm && mounted) {
      final result = await context.read<RentalOrderViewModel>().rejectRequest(
            rentalRequestId: order.id,
            cancelReason: "Chủ shop từ chối vì hết mặt hàng lưu kho.",
          );

      if (mounted && result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đã từ chối đơn hàng và hoàn cọc cho khách!")));
        Navigator.pop(context);
      }
    }
  }

  void _handleApproveOrder(BuildContext context, dynamic order) async {
    final result = await context.read<RentalOrderViewModel>().approveRequest(order.id);
    if (mounted && result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Duyệt đơn hàng thành công! Hóa đơn Invoice đã được khởi tạo.")));
      Navigator.pop(context);
    }
  }

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