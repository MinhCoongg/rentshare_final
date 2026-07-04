import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentshare_app/utils/dialog_confirm.dart';
import 'package:rentshare_app/utils/format_utils.dart';
import 'package:rentshare_app/viewmodels/AdminProductViewModel.dart';
import 'package:rentshare_app/views/product_detail.dart/product_detail_screen.dart';


class AdminProductScreen extends StatefulWidget {
  const AdminProductScreen({super.key});
  @override
  State<AdminProductScreen> createState() => _AdminProductScreenState();
}

class _AdminProductScreenState extends State<AdminProductScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProductViewModel>().loadProducts(''); 
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  _buildStatsRow(),
                  const SizedBox(height: 24),
                  _buildFilterBar(),
                  const SizedBox(height: 16),
                  _buildProductTable(),
                ],
              ),
            ),
          ),
          //Expanded(flex: 1, child: _buildRightSidebar()),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Consumer<AdminProductViewModel>(builder: (context, vm, _) {
      return Row(
        children: [
          _statCard("Chờ duyệt", vm.stats['Pending'].toString(), Colors.purple, Icons.assignment_outlined),
          _statCard("Đã phê duyệt", vm.stats['Available'].toString(), Colors.green, Icons.check_circle_outline),
          _statCard("Từ chối", vm.stats['Hidden'].toString(), Colors.red, Icons.cancel_outlined),
          _statCard("Tổng số", vm.stats['Total'].toString(), Colors.orange, Icons.inventory_outlined),
        ],
      );
    });
  }

  Widget _statCard(String title, String count, Color color, IconData icon) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200), 
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(count, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
                const SizedBox(height: 4),
                Text(title, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
    child: Row(
      children: [
        Expanded(
          child: TextField(
            decoration: const InputDecoration(
              hintText: "Tìm kiếm sản phẩm, người đăng...", 
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            ),
            onChanged: (value) {
              context.read<AdminProductViewModel>().searchProducts(value);
            },
          ),
        ),
        const SizedBox(width: 16),

        Consumer<AdminProductViewModel>(builder: (context, vm, _) {
          final String currentValure = vm.selectedStatus.isEmpty ? '' : vm.selectedStatus;
          return DropdownButton<String>(
            value: currentValure,
            hint: const Text("Tất cả trạng thái"),
            items: const [
              DropdownMenuItem(value: '', child: Text("Tất cả")),
              DropdownMenuItem(value: 'Pending', child: Text("Chờ duyệt")),
              DropdownMenuItem(value: 'Available', child: Text("Đã phê duyệt")),
              DropdownMenuItem(value: 'Hidden', child: Text("Từ chối")),
            ],
            onChanged: (val) => vm.filterByStatus(val ?? ''),
          );
        }),
      ],
    ),
  );
}

  Widget _buildProductTable() {
    return Container(
      color: Colors.white,
      child: Consumer<AdminProductViewModel>(builder: (context, vm, _) {
        if (vm.isLoading) return Center(child: CircularProgressIndicator());
        return DataTable(
          columns: const [
            DataColumn(label: Text('SẢN PHẨM')),
            DataColumn(label: Text('NGƯỜI ĐĂNG')),
            DataColumn(label: Text('GIÁ THUÊ')),
            DataColumn(label: Text('TRẠNG THÁI')),
            DataColumn(label: Text('THAO TÁC')),
          ],
          rows: vm.products.map((p) => DataRow(cells: [
            DataCell(
              SizedBox(
                width: 250, 
                child: Row(
                  children: [
                    Image.network(
                      'http://192.168.1.17:3001${p.imageUrl}', 
                      width: 40, height: 40, fit: BoxFit.cover,
                      errorBuilder: (c, o, s) => const Icon(Icons.image_not_supported),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        p.title,
                        overflow: TextOverflow.ellipsis, 
                        maxLines: 1, 
                      ),
                    ),
                  ],
                ),
              ),
            ),
            DataCell(Text(p.ownerName)),
            DataCell(Text("${FormatUtils.formatMoney(double.parse(p.pricePerDay))}đ/ngày")),
            DataCell(
              Chip(
                label: Text(
                  translateStatus(p.status),
                  style: const TextStyle(fontSize: 12),
                ),
                backgroundColor: getStatusColor(p.status),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), 
              ),
            ),
            DataCell(Row(children: [
              IconButton(
                icon: const Icon(Icons.remove_red_eye, color: Colors.blue),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductDetailPage(
                        productId: p.id, 
                        isAdmin: true, 
                      ),
                    ),
                  );
                },
              ),
              if (p.status != 'Hidden')
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red), 
                  onPressed: () async {
                    bool confirmed = await DifferentShopDialog.show(
                      context: context,
                      title: "Xác nhận từ chối",
                      content: "Bạn có chắc chắn muốn từ chối sản phẩm này? Sản phẩm sẽ bị ẩn khỏi danh sách công khai.",
                      actionButtonText: "Đồng ý từ chối",
                    );

                    if (confirmed) {
                      vm.approveOrReject(p.id, 'Hidden', 'Pending');
                      _showSnackBar("Đã từ chối sản phẩm thành công!");
                    }
                  },
                ),
              if(p.status == 'Pending')
                IconButton(
                  icon: const Icon(Icons.check, color: Colors.green), 
                  onPressed: () async {
                    bool confirmed = await DifferentShopDialog.show(
                      context: context,
                      title: "Xác nhận duyệt",
                      content: "Bạn có chắc chắn muốn duyệt sản phẩm này không?",
                      actionButtonText: "Đồng ý duyệt",
                    );
                    if (confirmed) {
                      vm.approveOrReject(p.id, 'Available', 'Pending');
                      _showSnackBar("Đã duyệt thành công!");
                    }
                  },
              ),
            ])),
          ])).toList(),
        );
      }),
    );
  }

  

  String translateStatus(String status) {
    switch (status) {
      case 'Pending': return 'Chờ duyệt';
      case 'Available': return 'Đã phê duyệt';
      case 'Hidden': return 'Từ chối';
      default: return status;
    }
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'Pending': return Colors.purple.shade100;
      case 'Available': return Colors.green.shade100;
      case 'Hidden': return Colors.red.shade100;
      default: return Colors.grey.shade100;
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green,
      ),
      
    );
  }
}