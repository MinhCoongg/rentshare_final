import 'package:flutter/material.dart';
import 'package:rentshare_app/models/rentalOrderItem.dart';
import 'package:rentshare_app/utils/format_utils.dart';

class RentalOrderCard extends StatelessWidget {
  final RentalOrderModel order;
  final VoidCallback? onDetailPressed;
  final VoidCallback? onContactPressed;

  const RentalOrderCard({
    super.key,
    required this.order,
    this.onDetailPressed,
    this.onContactPressed,
  });

 

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Mã đơn: ${order.orderCode}",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Ngày đặt: ${order.orderDate}",
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.access_time, color: Colors.orange[700], size: 16),
                    const SizedBox(width: 4),
                    Text(
                      order.status == 'Pending' ? 'Chờ duyệt' : order.status,
                      style: TextStyle(color: Colors.orange[700], fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ],
                )
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFF3F4F6)),

          ...order.items.map((item) {
            double price = item.pricePerDay is String ? double.parse(item.pricePerDay as String) : (item.pricePerDay as num).toDouble();
            double itemTotal = price * order.rentalDays * item.quantity;

            return Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      item.image,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[200],
                        child: const Icon(Icons.image, color: Colors.grey),
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
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const SizedBox(height: 6),
                        Text("x ${item.quantity}", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.calendar_month_outlined, color: Colors.grey[500], size: 14),
                            const SizedBox(width: 4),
                            Text(
                              "${order.rentalDays} ngày",
                              style: TextStyle(color: Colors.grey[600], fontSize: 12),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  Text(
                    "${FormatUtils.formatMoney(itemTotal)} đ",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  )
                ],
              ),
            );
          }),

          const Divider(height: 1, thickness: 1, color: Color(0xFFF3F4F6)),

          // 3. Địa chỉ thông tin người nhận hàng
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(Icons.local_shipping_outlined, color: Colors.grey[500], size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${order.receiverName} - ${order.receiverPhone}",
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        order.fullAddress,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      )
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.grey)
              ],
            ),
          ),

          const Divider(height: 1, thickness: 1, color: Color(0xFFF3F4F6)),

          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      order.status == 'Pending' ? "Tiền cọc đang giữ" : "Tổng tiền",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          order.status == 'Pending'
                              ? "${FormatUtils.formatMoney(order.depositFee)} đ" // Bản Chờ duyệt show đúng 2.5 triệu cọc
                              : "${FormatUtils.formatMoney(order.totalAmount)} đ",
                          style: const TextStyle(color: Color(0xFFE07A5F), fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Row(
                          children: [
                            Text(
                              order.status == 'Pending' ? "Đang đóng băng tạm thời" : "Đã thanh toán bằng ví",
                              style: TextStyle(color: Colors.grey[500], fontSize: 11),
                            ),
                            const SizedBox(width: 2),
                            Icon(Icons.help_outline, color: Colors.grey[400], size: 12)
                          ],
                        )
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFE07A5F)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        icon: const Icon(Icons.assignment_outlined, color: Color(0xFFE07A5F), size: 16),
                        label: const Text("Xem chi tiết", style: TextStyle(color: Color(0xFFE07A5F), fontWeight: FontWeight.bold)),
                        onPressed: onDetailPressed,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey[300]!),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        icon: Icon(Icons.chat_bubble_outline, color: Colors.grey[700], size: 16),
                        label: Text("Liên hệ shop", style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.bold)),
                        onPressed: onContactPressed,
                      ),
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class Convert {
  static double toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}