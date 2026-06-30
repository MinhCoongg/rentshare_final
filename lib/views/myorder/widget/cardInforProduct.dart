import 'package:flutter/material.dart';
import 'package:rentshare_app/models/rentalOrderDetail.dart';
import 'package:rentshare_app/utils/format_utils.dart';
import 'package:rentshare_app/views/review/reviewProduct.dart';

class RentalOrderCard extends StatelessWidget {
  final RentalOrderDetailModel order;
  final VoidCallback? onDetailPressed;
  final VoidCallback? onContactPressed;

  const RentalOrderCard({
    super.key,
    required this.order,
    this.onDetailPressed,
    this.onContactPressed,
  });

  String _getStatus(String status) {
    switch (status) {
      case 'Pending': return 'Chờ duyệt';
      case 'Approved': return 'Đã duyệt';
      case 'Shipping': return 'Đang giao';
      case 'Delivered': return 'Đang thuê';
      case 'Returned': return 'Chờ trả';
      case 'Inspecting': return 'Nghiệm thu';
      case 'Completed': return 'Hoàn tất';
      case 'Cancelled': return 'Đã hủy';
      default: return status;
    }
  }

  @override
  Widget build(BuildContext context) {
   final bool allReviewed = order.items.every((item) => item.isReviewed);
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Mã đơn: ${order.orderCode}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    SizedBox(height: 4),
                    Text("Ngày đặt: ${order.orderDate}", style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.access_time, color: Colors.orange[700], size: 16),
                    SizedBox(width: 4),
                    Text(_getStatus(order.status), style: TextStyle(color: Colors.orange[700], fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                )
              ],
            ),
          ),
          Divider(height: 1, thickness: 1, color: Color(0xFFF3F4F6)),

          ...order.items.map((item) {
            double price = double.parse(item.pricePerDay);
            double itemTotal = price * order.rentalDays * item.quantity;

            return Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(item.image, width: 80, height: 80, fit: BoxFit.cover),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            SizedBox(height: 6),
                            Text("x ${item.quantity}", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                          ],
                        ),
                      ),
                      Text("${FormatUtils.formatMoney(itemTotal)} đ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    ],
                  ),
                ],
              ),
            );
          }),
          Divider(height: 1, thickness: 1, color: Color(0xFFF3F4F6)),
          Padding(
            padding: EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(Icons.local_shipping_outlined, color: Colors.grey[500], size: 20),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("${order.receiverName} - ${order.receiverPhone}", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                      SizedBox(height: 2),
                      Text(order.fullAddress, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: Colors.grey)
              ],
            ),
          ),
          Divider(height: 1, thickness: 1, color: Color(0xFFF3F4F6)),
          Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(order.status == 'Pending' ? "Tiền cọc đang giữ" : "Tổng tiền", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          order.status == 'Pending' ? "${FormatUtils.formatMoney(double.parse(order.depositFee))} đ" : "${FormatUtils.formatMoney(double.parse(order.totalAmount))} đ",
                          style: TextStyle(color: Color(0xFFE07A5F), fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Row(
                          children: [
                            Text(order.status == 'Pending' ? "Đang đóng băng tạm thời" : "Đã thanh toán bằng ví", style: TextStyle(color: Colors.grey[500], fontSize: 11)),
                            SizedBox(width: 2),
                            Icon(Icons.help_outline, color: Colors.grey[400], size: 12)
                          ],
                        )
                      ],
                    )
                  ],
                ),
                SizedBox(height: 12),
                Column(
                  children: [
                    if (order.status == 'Inspecting')
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                            icon: Icon(Icons.assignment_turned_in_outlined, color: Colors.white, size: 16),
                            label: Text("Xem báo cáo", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            onPressed: onDetailPressed,
                          ),
                        ),
                      ),

                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: SizedBox(
                        width: double.infinity,
                        child: order.status == 'Completed'
                            ? (allReviewed
                                ? OutlinedButton(
                                    onPressed: null,
                                    style: OutlinedButton.styleFrom(backgroundColor: Colors.grey[200]),
                                    child: Text("Đã đánh giá tất cả"),
                                  )
                                : ElevatedButton(
                                    onPressed: () => _openReviewSelector(context, order),
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                                    child: Text("Đánh giá sản phẩm", style: TextStyle(color: Colors.white)),
                                  ))
                            : OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(side: BorderSide(color: Color(0xFFE07A5F)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                                icon: Icon(Icons.assignment_outlined, color: Color(0xFFE07A5F), size: 16),
                                label: Text("Xem chi tiết đơn hàng", style: TextStyle(color: Color(0xFFE07A5F), fontWeight: FontWeight.bold)),
                                onPressed: onDetailPressed,
                              ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openReviewSelector(BuildContext context, RentalOrderDetailModel order) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Chọn sản phẩm để đánh giá", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ...order.items.map((item) {
                return ListTile(
                  leading: Image.network(item.image, width: 50, height: 50),
                  title: Text(item.title),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => WriteReviewScreen(item: item, idInvoiceDetail: item.idInvoiceDetail)));
                  },
                );
              })
            ],
          ),
        );
      },
    );
  }
}
