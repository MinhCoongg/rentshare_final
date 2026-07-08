import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentshare_app/utils/format_utils.dart';
import 'package:rentshare_app/viewmodels/AdminProductViewModel.dart';
import 'package:rentshare_app/views/Admin/utils/star_card.dart';

class RentalManagementScreen extends StatefulWidget {
  const RentalManagementScreen({super.key});

  @override
  State<RentalManagementScreen> createState() => _RentalManagementScreenState();
}

class _RentalManagementScreenState extends State<RentalManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProductViewModel>().loadOrders(status: '');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      // Bỏ Row, dùng thẳng Padding hoặc đặt trực tiếp
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildStatsHeader(),
            const SizedBox(height: 24),
            _buildFilterBar(),
            const SizedBox(height: 16),
            
            // Bảng sẽ tự động giãn ra chiếm hết không gian còn lại
            Expanded(child: _buildOrderTable()),
            
            const SizedBox(height: 16),
            Consumer<AdminProductViewModel>(
              builder: (context, vm, _) {
                return vm.orders.isEmpty ? const SizedBox() : _buildPagination(vm);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsHeader() {
    return 
      Consumer<AdminProductViewModel>(builder: (context, vm, _) {
        return Row(
          children: [
            Expanded(child: StatCard(title: "Tất cả đơn", count: "${vm.statsus['totalOrders']}", color: Colors.purple, icon: Icons.assignment)),
            const SizedBox(width: 16),
            Expanded(child: StatCard(title: "Chờ duyệt", count: "${vm.statsus['pendingOrders']}", color: Colors.orange, icon: Icons.timer)),
            const SizedBox(width: 16),
            Expanded(child: StatCard(title: "Đang thuê", count: "${vm.statsus['rentingOrders']}", color: Colors.blue, icon: Icons.inventory)),
            const SizedBox(width: 16),
            Expanded(child: StatCard(title: "Hoàn tất", count: "${vm.statsus['completedOrders']}", color: Colors.green, icon: Icons.check_circle)),
          ],
        );
      });
  }

  Widget _buildOrderTable() {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Consumer<AdminProductViewModel>(builder: (context, vm, _) {
        if (vm.isLoading) return const Center(child: CircularProgressIndicator());
        
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('MÃ ĐƠN')),
              DataColumn(label: Text('SẢN PHẨM')),
              DataColumn(label: Text('NGƯỜI THUÊ')),
              DataColumn(label: Text('CHỦ SHOP')),
              DataColumn(label: Text('TỔNG TIỀN')),
              DataColumn(label: Text('TRẠNG THÁI')),
            ],
            rows: vm.orders.map((order) {
              return DataRow(cells: [
                DataCell(Text(order.orderCode, style: const TextStyle(fontWeight: FontWeight.bold))),
               DataCell(
                SizedBox(
                  width: 150,
                  child: Row(
                    children: [
                      Image.network(order.productImage, width: 40, height: 40, fit: BoxFit.cover),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          order.productName,
                          overflow: TextOverflow.ellipsis, 
                          maxLines: 1, 
                        ),
                      ),
                    ],
                  ),
                ),
              ),
                DataCell(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(order.renterName), Text(order.renterPhone, style: TextStyle(fontSize: 11))])),
                DataCell(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(order.ownerName), Text(order.ownerPhone, style: TextStyle(fontSize: 11))])),
                DataCell(Text("${FormatUtils.formatMoney(order.netIncome)}đ")),
                DataCell(
                  Chip(
                    label: Text(
                      rentalStatusViMap[order.status] ?? order.status, 
                      style: const TextStyle(fontSize: 12),
                    ),
                    backgroundColor: _getStatusColor(order.status),
                  ),
                ),
              ]);
            }).toList(),
          ),
        );
      }),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Completed': return Colors.green.shade100;  
      case 'Delivered': 
      case 'Returned': return Colors.blue.shade100;     
      case 'Pending': 
      case 'Approved': return Colors.orange.shade100;   
      case 'Inspecting': return Colors.purple.shade100; 
      case 'Cancelled': return Colors.red.shade100;    
      case 'Overdue': return Colors.red.shade200;       
      default: return Colors.grey.shade100;
    }
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: const InputDecoration(hintText: "Tìm kiếm mã đơn, người thuê...", prefixIcon: Icon(Icons.search), border: OutlineInputBorder()),
             onChanged: (val) => context.read<AdminProductViewModel>().searchOrders(val),
            ),
          ),
          const SizedBox(width: 16),
          Consumer<AdminProductViewModel>(builder: (context, vm, _) {
            return DropdownButton<String>(
              value: vm.selectedStatus.isEmpty ? 'All' : vm.selectedStatus,
              items: statusMap.keys.map((String key) {
                return DropdownMenuItem<String>(
                  value: statusMap[key], 
                  child: Text(key),
                );
              }).toList(),
              onChanged: (val) => vm.filterOrderByStatus(val ?? 'All'),
            );
          }),
        ],
      ),
    );
  }

  final Map<String, String> statusMap = {
    'Tất cả': 'All',
    'Chờ duyệt': 'Pending',
    'Đang thuê': 'Delivered', 
    'Hoàn tất': 'Completed',
    'Đã hủy': 'Cancelled',
  };

  final Map<String, String> rentalStatusViMap = {
    'Pending': 'Chờ duyệt',
    'Approved': 'Đã duyệt',
    'Shipping': 'Đang giao',
    'Delivered': 'Đã giao',
    'Returned': 'Đã trả',
    'Inspecting': 'Đang nghiệm thu',
    'Completed': 'Hoàn tất',
    'Cancelled': 'Đã hủy',
    'Overdue': 'Quá hạn',
  };

  Widget _buildPagination(AdminProductViewModel vm) {
    int totalPages = vm.totalPages;
    if (totalPages <= 1) return const SizedBox();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: vm.currentPage > 1 ? () => vm.loadOrders(page: vm.currentPage - 1) : null,
        ),
        

        ...List.generate(totalPages, (index) {
          int pageNum = index + 1;
          if (totalPages > 7 && pageNum > 3 && pageNum < totalPages - 2) {
            if (pageNum == 4) return const Padding(padding: EdgeInsets.symmetric(horizontal: 4), child: Text("..."));
            return const SizedBox.shrink();
          }
          return _buildPageItem(pageNum, vm.currentPage == pageNum, () => vm.loadOrders(page: pageNum));
        }),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: vm.currentPage < totalPages ? () => vm.loadOrders(page: vm.currentPage + 1) : null,
        ),
      ],
    );
  }


  Widget _buildPageItem(int page, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.purple : Colors.white,
          borderRadius: BorderRadius.circular(8), 
          border: Border.all(color: isSelected ? Colors.purple : Colors.grey.shade300),
        ),
        child: Text("$page", style: TextStyle(color: isSelected ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
      ),
    );
  }
}