import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentshare_app/models/producthome_model.dart';
import 'package:rentshare_app/utils/format_utils.dart';
import 'package:rentshare_app/viewmodels/shop_viewmodel.dart';
import 'package:rentshare_app/views/product_detail.dart/product_detail_screen.dart';

class OwnerProductPage extends StatelessWidget {
  const OwnerProductPage({super.key});
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ShopViewModel>(context, listen: false).fetchProducts();
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text("Quản lý sản phẩm"), 
        backgroundColor: Colors.white,
      ),
      body: Consumer<ShopViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF1B8A4B)));
          }
          
          if (vm.products.isEmpty) {
            return const Center(child: Text("Chưa có sản phẩm nào!"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: vm.products.length,
            itemBuilder: (context, index) {
              final product = vm.products[index];
              return _buildProductCard(context, vm, product);
            },
          );
        },
      ),
    );
  }


  Widget _buildProductCard(context, ShopViewModel vm, ProductHomeModel product) {
    bool isHidden = product.status == 'Hidden';
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(product.images, width: 80, height: 80, fit: BoxFit.cover),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(product.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 5),
                      Text("Giá: ${FormatUtils.formatMoney(double.parse(product.depositAmount))}đ", style: const TextStyle(color: Color(0xFF1B8A4B))),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Nút Xem
                OutlinedButton.icon(
                  onPressed: () { 
                      Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailPage(productId: product.id)));
                   },
                  icon: const Icon(Icons.remove_red_eye_outlined, size: 16),
                  label: const Text("Xem"),
                ),
                const SizedBox(width: 10),
                // Nút Ẩn/Hiện
                OutlinedButton.icon(
                  icon: Icon(
                    isHidden ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    size: 16,
                    color: isHidden ? Colors.green : Colors.orange,
                  ),
                  label: Text(isHidden ? "Hiện sản phẩm" : "Ẩn sản phẩm"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isHidden ? Colors.green : Colors.orange,
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(isHidden ? "Xác nhận hiện sản phẩm" : "Xác nhận ẩn sản phẩm"),
                        content: Text(isHidden 
                            ? "Bạn muốn hiển thị sản phẩm này lên danh sách cho thuê?" 
                            : "Sản phẩm sẽ bị ẩn và khách hàng không thể tìm thấy. Bạn có chắc chắn muốn ẩn?"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Hủy", style: TextStyle(color: Colors.grey)),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isHidden ? Colors.green : Colors.orange,
                            ),
                            onPressed: () {
                              Navigator.pop(context); 
                              vm.toggleStatus(product.id, product.status, context);
                            },
                            child: Text(isHidden ? "Hiện ngay" : "Ẩn ngay"),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}