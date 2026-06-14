import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentshare_app/utils/dialog_confirm.dart';
import 'package:rentshare_app/utils/format_utils.dart';
import 'package:rentshare_app/viewmodels/rental_cart_viewmodel.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<RentalCartProvider>();
    final cartItems = cartProvider.items;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD), 
      appBar: AppBar(
        title: const Text(
          "Đơn thuê của tôi",
          style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: const BackButton(color: Colors.black),
      ),
      body: cartItems.isEmpty
          ? const Center(
              child: Text(
                "Đơn thuê đang trống! Quay lại chọn đồ nhé.",
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.only(bottom: 24),
                    children: [
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6366F1), Color(0xFF4F46E5)], 
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                            radius: 16, 
                            backgroundColor: Colors.white.withValues(alpha: 0.2),
                            backgroundImage: (cartItems.isNotEmpty && cartItems.first.ownerAvatar.isNotEmpty)
                                ? NetworkImage(cartItems.first.ownerAvatar)
                                : null,
                            child: (cartItems.isEmpty || cartItems.first.ownerAvatar.isEmpty)
                                ? const Icon(Icons.person_rounded, color: Colors.white, size: 18)
                                : null,
                          ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Bạn đang thuê từ shop",
                                    style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 11),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    cartItems.first.ownerName, 
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right_rounded, color: Colors.white, size: 22),
                          ],
                        ),
                      ),

                      ...List.generate(cartItems.length, (index) {
                        final item = cartItems[index];
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.015),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              )
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: item.image.isNotEmpty
                                    ? Image.network(item.image, width: 75, height: 75, fit: BoxFit.cover)
                                    : Container(width: 75, height: 75, color: Colors.grey[200]),
                              ),
                              const SizedBox(width: 12),
                              
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            item.title,
                                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5, color: Colors.black),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        
                                        GestureDetector(
                                        onTap: () async {
                                          bool confirmDelete = await DifferentShopDialog.show(
                                            context: context,
                                            title: "Xác nhận xóa đồ",
                                            content: "Bạn có chắc chắn muốn xóa sản phẩm '${item.title}' ra khỏi đơn thuê không?",
                                            actionButtonText: "Xóa ngay", 
                                           
                                          );
                                          
                                          if (confirmDelete) {
                                            await cartProvider.removeFromCart(item.productId);
                                            
                                            if (!context.mounted) return;
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text("Đã xóa '${item.title}' thành công!"),
                                                backgroundColor: const Color(0xFF1B8A4B),
                                                duration: const Duration(milliseconds: 800),
                                              ),
                                            );
                                          }
                                        },
                                        child: Icon(Icons.delete_outline_rounded, color: Colors.grey[400], size: 18),
                                      ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "${FormatUtils.formatMoney(item.pricePerDay)}đ / ngày",
                                      style: const TextStyle(color: Color(0xFF6366F1), fontWeight: FontWeight.bold, fontSize: 13),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      "Số lượng: ${item.quantity}",
                                      style: TextStyle(color: Colors.grey[400], fontSize: 11),
                                    ),
                                    const SizedBox(height: 4),
                                    
                                   
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        _buildQtyBtn(
                                        icon: Icons.remove_rounded,
                                        onTap: () async {
                                          if (item.quantity > 1) {
                                            await cartProvider.decreaseQuantity(item.productId); 
                                          } 
                                          else {
                                            if (!context.mounted) return;
                                            bool confirmDelete = await DifferentShopDialog.show(
                                              context: context,
                                              title: "Xác nhận xóa đồ",
                                              content: "Số lượng đã về mức tối thiểu. Bạn có chắc chắn muốn xóa sản phẩm '${item.title}' ra khỏi đơn thuê không?",
                                              actionButtonText: "Xóa ngay",
                                            );

                                            if (confirmDelete) {
                                              await cartProvider.removeFromCart(item.productId);
                                              
                                              if (!context.mounted) return;
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text("Đã xóa '${item.title}' thành công!"),
                                                  backgroundColor: const Color(0xFF1B8A4B),
                                                  duration: const Duration(milliseconds: 800),
                                                ),
                                              );
                                            }
                                          }
                                        },
                                      ),
                                        Container(
                                          constraints: const BoxConstraints(minWidth: 32), 
                                          child: Text(
                                            "${item.quantity}",
                                            textAlign: TextAlign.center, 
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
                                          ),
                                        ),
                                        _buildQtyBtn(
                                          icon: Icons.add_rounded,
                                          onTap: () async {
                                            int currentStockInDB = item.maxStock; 
                                            bool isIncreased = await cartProvider.increaseQuantityWithCheck(item.productId, currentStockInDB);
                                            if (!isIncreased) {
                                              if (!context.mounted) return;
                                              await DifferentShopDialog.show(
                                                context: context,
                                                title: "Không đủ số lượng",
                                                content: "Hiện tại kho của chủ shop chỉ còn đúng $currentStockInDB sản phẩm, không thể tăng thêm được nữa!",
                                                actionButtonText: "Đã hiểu",
                                              );
                                            }
                                          },
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }),

                  
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () => Navigator.pop(context), 
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F4FF), 
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_rounded, color: Color(0xFF0056D2), size: 16),
                              SizedBox(width: 4),
                              Text(
                                "Thêm sản phẩm khác",
                                style: TextStyle(color: Color(0xFF0056D2), fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.01),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            )
                          ],
                        ),
                        child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Tổng quan đơn thuê",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black),
                          ),
                          const SizedBox(height: 14),
                          _buildSummaryRow(
                            "Tổng tiền thuê (ước tính)", 
                            "${FormatUtils.formatMoney(cartProvider.totalRentalFeePerDay)} đ"
                          ),
                          const SizedBox(height: 10),
                          _buildSummaryRow(
                            "Tiền cọc (hoàn lại)", 
                            "${FormatUtils.formatMoney(cartProvider.totalDeposit)}đ"
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Phí giao hàng (ước tính)", 
                                style: TextStyle(color: Colors.grey[500], fontSize: 13, fontWeight: FontWeight.w400)
                              ),
                              Text(
                                "Chưa xác định",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.redAccent),
                              ),
                            ],
                          ),
                          
                          const Divider(height: 28, thickness: 0.5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween, 
                            children: [
                              const Text(
                                "Tổng cộng",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
                              ),
                              const Text(
                                "Chưa xác định",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.redAccent),
                              ),
                            ],
                          ),
                        ],
                      ),
                      ),
                    ],
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
                        backgroundColor: const Color(0xFF4F46E5), // Chuẩn tông màu tím xanh bốc lửa thương hiệu
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                      ),
                      onPressed: () {
                        // Kích hoạt tuyến đường mở sang trang chọn thời gian và phương thức thanh toán tiếp theo!
                      },
                      child: const Text(
                        "Tiến hành thuê",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                  ),
                )
              ],
            ),
    );
  }

 
  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween, 
      children: [
        Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 13, fontWeight: FontWeight.w400)),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black87),
        ),
      ],
    );
  }

  Widget _buildQtyBtn({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6), 
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 15, color: Colors.black),
      ),
    );
  }
}