import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentshare_app/utils/format_utils.dart';
import 'package:rentshare_app/viewmodels/rental_order_viewmodel.dart';

class OwnerRentalListScreen extends StatefulWidget {
  const OwnerRentalListScreen({super.key});

  @override
  State<OwnerRentalListScreen> createState() => _OwnerRentalListScreenState();
}

class _OwnerRentalListScreenState extends State<OwnerRentalListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchOrdersByTab(0);
    });

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _fetchOrdersByTab(_tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _fetchOrdersByTab(int index) {
    final viewModel = context.read<RentalOrderViewModel>();
    switch (index) {
      case 0: viewModel.loadOwnerOrders(status: 'Pending'); break;
      case 1: viewModel.loadOwnerOrders(status: 'Shipping'); break;
      case 2: viewModel.loadOwnerOrders(status: 'Delivered'); break;
      case 3: viewModel.loadOwnerOrders(status: 'Returned'); break;
      case 4: viewModel.loadOwnerOrders(status: 'Inspecting'); break;
      case 5: viewModel.loadOwnerOrders(status: 'Completed'); break;
    }
  }

  String _getCurrentStatusByIndex(int index) {
    switch (index) {
      case 0: return 'Pending';
      case 1: return 'Shipping';
      case 2: return 'Delivered';
      case 3: return 'Returned';
      case 4: return 'Inspecting';
      default: return 'Completed';
    }
  }

  Widget _buildAlertBanner(int tabIndex) {
    String text = "";
    Color bgColor = Colors.white;
    Color textColor = Colors.black87;
    IconData icon = Icons.info_outline;

    if (tabIndex == 0) {
      text = "Đơn hàng mới đang chờ bạn duyệt. Vui lòng kiểm tra kỹ thông tin.";
      bgColor = const Color(0xFFE8F0FE); textColor = const Color(0xFF1A73E8); icon = Icons.pending_actions;
    } else if (tabIndex == 1) {
      text = "Vui lòng giao hàng cho khách và cập nhật khi đơn vị vận chuyển nhận hàng.";
      bgColor = const Color(0xFFFFF4E5); textColor = const Color(0xFFB76E00); icon = Icons.local_shipping_outlined;
    } else if (tabIndex == 2) {
      text = "Khách đang thuê sản phẩm. Vui lòng theo dõi thời hạn và chờ khách trả hàng.";
      bgColor = const Color(0xFFE6F4EA); textColor = const Color(0xFF137333); icon = Icons.vpn_key_outlined;
    } else if (tabIndex == 3) {
      text = "Khách đã báo trả hàng. Vui lòng xác nhận khi bạn nhận lại và kiểm tra sản phẩm.";
      bgColor = const Color(0xFFF3E5F5); textColor = const Color(0xFF7B1FA2); icon = Icons.assignment_return_outlined;
    } else if (tabIndex == 4) { 
      text = "Sản phẩm đang trong quá trình nghiệm thu. Vui lòng chờ khách xác nhận hoặc khiếu nại nếu quá 24h.";
      bgColor = const Color(0xFFFFF3E0); textColor = const Color(0xFFEF6C00); icon = Icons.pending_actions;
    }else {
      text = "Tổng đơn hoàn tất. Tiền thuê đã được giải ngân vào ví của bạn.";
      bgColor = const Color(0xFFE8F5E9); textColor = const Color(0xFF2E7D32); icon = Icons.check_circle_outline;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(icon, color: textColor, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF00B4D8);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8), // Đổi nền xám nhạt nhẹ cho nổi Card trắng
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Quản lý đơn thuê (Shop)",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: primaryColor,
              unselectedLabelColor: Colors.grey[500],
              indicatorColor: primaryColor,
              indicatorWeight: 3,
              isScrollable: true,
              indicatorSize: TabBarIndicatorSize.label, 
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              tabs: const [
                Tab(text: "Chờ duyệt"), Tab(text: "Đang giao"), Tab(text: "Đang thuê"), Tab(text: "Chờ trả"),Tab(text: "Nghiệm thu"), Tab(text: "Hoàn tất"),
              ],
            ),
          ),
        ),
      ),
      body: Consumer<RentalOrderViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator(color: primaryColor));
          }

          final int totalOrders = viewModel.ownerOrders.length; 
          double totalRevenue = 0;
          for (var order in viewModel.ownerOrders) {
            totalRevenue += order.rentalFee; 
          }

          return Column(
            children: [
              // 📊 Card Tím Tổng Quan
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4361EE), Color(0xFF3F37C9)], // Chuốt lại hệ màu mượt hơn
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: const Color(0xFF3F37C9).withOpacity(0.15), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.assignment_turned_in_outlined, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_tabController.index == 0 ? "Tổng đơn chờ duyệt" : _tabController.index == 4 ? "Tổng đơn hoàn tất" : "Tổng đơn trong danh mục này", style: const TextStyle(color: Colors.white70, fontSize: 12)),
                          const SizedBox(height: 4),
                          Text("$totalOrders đơn", style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(_tabController.index == 4 ? "Tổng doanh thu: ${FormatUtils.formatMoney(totalRevenue)}đ" : "Tổng giá trị: ${FormatUtils.formatMoney(totalRevenue)}đ", style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    )
                  ],
                ),
              ),

              _buildAlertBanner(_tabController.index),
              const SizedBox(height: 8),
              Expanded(
                child: viewModel.ownerOrders.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.folder_open_outlined, size: 44, color: Colors.grey[400]),
                            const SizedBox(height: 10),
                            Text("Không có đơn hàng nào!", style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        color: primaryColor,
                        onRefresh: () async {
                          await viewModel.loadOwnerOrders(status: _getCurrentStatusByIndex(_tabController.index));
                        },
                        child: ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: viewModel.ownerOrders.length,
                          itemBuilder: (context, index) {
                            final order = viewModel.ownerOrders[index];
                            String displayStatus = "Đang thuê";
                            Color tagBgColor = const Color(0xFFE6F4EA);
                            Color tagTextColor = const Color(0xFF137333);
                            if (order.status == 'Pending') { displayStatus = 'Mới'; tagBgColor = const Color(0xFFFFEAEA); tagTextColor = Colors.red; }
                            else if (order.status == 'Shipping') { displayStatus = 'Chờ giao'; tagBgColor = const Color(0xFFE8F0FE); tagTextColor = const Color(0xFF1A73E8); }
                            else if (order.status == 'Returned') { displayStatus = 'Chờ nhận hàng'; tagBgColor = const Color(0xFFF3E5F5); tagTextColor = const Color(0xFF7B1FA2); }
                            else if (order.status == 'Completed') { displayStatus = 'Hoàn tất'; tagBgColor = const Color(0xFFE8F5E9); tagTextColor = const Color(0xFF2E7D32); }
                            else if (order.status == 'Inspecting') { displayStatus = 'Nghiệm thu'; tagBgColor = Colors.orange.withOpacity(0.1); tagTextColor = Colors.orange; }
                            return Card(
                              elevation: 0,
                              margin: const EdgeInsets.only(bottom: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(color: Colors.grey.withOpacity(0.1)),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Header
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("ORD-${order.orderCode.replaceAll('#RS', '')}", 
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                        _buildStatusTag(displayStatus, tagBgColor, tagTextColor),
                                      ],
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.symmetric(vertical: 12),
                                      child: Divider(height: 1, thickness: 1, color: Color(0xFFF3F4F6)),
                                    ),
                                    
                                    // Body info (Gọn gàng hơn)
                                    _buildInfoRow(Icons.person_outline, "Khách:", order.receiverName),
                                    const SizedBox(height: 8),
                                    _buildInfoRow(Icons.calendar_today_outlined, "Thời gian:", "${order.startDate} - ${order.endDate}"),
                                    
                                    const Divider(height: 24, thickness: 1, color: Color(0xFFF3F4F6)),
                                    
                                    // Footer: Giá + Nút
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("${_tabController.index == 4 ? "Doanh thu" : "Tiền cọc"}: ${FormatUtils.formatMoney(double.tryParse(order.depositFee.toString()) ?? 0)}đ",
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
                                        _buildActionButton(order), 
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }


  Widget _buildStatusTag(String label, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: TextStyle(color: textColor, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }


  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey[400]),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
        const SizedBox(width: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
      ],
    );
  }

  Widget _buildActionButton(dynamic order) {
    return SizedBox(
      height: 32,
      child: OutlinedButton(
        onPressed: () {
          Navigator.pushNamed(context, '/owner-filter', arguments: order.id).then((_) {
            _fetchOrdersByTab(_tabController.index);
          });
        },
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFF00B4D8)), 
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
        ),
        child: const Text("Xem chi tiết", style: TextStyle(color: Color(0xFF00B4D8), fontSize: 11, fontWeight: FontWeight.bold)),
      ),
    );
  }
}