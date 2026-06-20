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
    _tabController = TabController(length: 3, vsync: this);
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
      case 0:
        viewModel.loadOwnerOrders(status: 'Pending'); // Chờ duyệt
        break;
      case 1:
        viewModel.loadOwnerOrders(status: 'Approved'); // Đang cho thuê (Có thể gộp Approved, Shipping, Delivered tùy DB của ní)
        break;
      case 2:
        viewModel.loadOwnerOrders(status: 'Completed'); // Đã hoàn thành
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF00B4D8); // Màu xanh RentShare thương hiệu

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Quản lý đơn thuê",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        // Cấu hình TabBar chuẩn chỉ kịch trần kẹp dưới AppBar
        bottom: TabBar(
          controller: _tabController,
          labelColor: primaryColor,
          unselectedLabelColor: Colors.grey[600],
          indicatorColor: primaryColor,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(text: "Chờ duyệt"),
            Tab(text: "Đang cho thuê"),
            Tab(text: "Đã hoàn thành"),
          ],
        ),
      ),
      body: Consumer<RentalOrderViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator(color: primaryColor));
          }

          // Tính toán tổng số đơn và tổng giá trị sơ bộ dựa trên danh sách đơn hiện tại để đổ lên Card tím
          final int totalOrders = viewModel.ownerOrders.length; 
          double totalValue = 0;
          for (var order in viewModel.ownerOrders) {
            totalValue += double.tryParse(order.totalAmount.toString()) ?? 0.0;
          }

          return Column(
            children: [
              // 📊 1. KHỐI CARD GRADIENT TÍM HIỂN THỊ SỐ LIỆU TỔNG QUAN Y XÌ FIGMA
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF5145CD), Color(0xFF3F37C9)], // Màu tím hoàng gia sang chảnh
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFF3F37C9).withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4))
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.assignment_outlined, color: Colors.white, size: 26),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Tổng đơn trong tab này", style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w400)),
                          const SizedBox(height: 2),
                          Text("$totalOrders đơn", style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 2),
                          Text("Tổng giá trị: ${FormatUtils.formatMoney(totalValue)}đ", style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    )
                  ],
                ),
              ),

              // 📋 2. DANH SÁCH LISTVIEW CÁC ĐƠN HÀNG THUÊ ĐỘNG ĐƯỢC LOAD VỀ
              // 📋 2. DANH SÁCH LISTVIEW CÁC ĐƠN HÀNG THUÊ ĐỘNG ĐƯỢC LOAD VỀ DÀNH CHO CHỦ SHOP
              Expanded(
                child: viewModel.ownerOrders.isEmpty // ✅ SỬA 1: Check danh sách ownerOrders trống
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.folder_open_outlined, size: 48, color: Colors.grey[400]),
                            const SizedBox(height: 12),
                            Text("Không có đơn hàng nào trong danh mục này!", style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: viewModel.ownerOrders.length, // ✅ SỬA 2: Đếm theo tổng số lượng ownerOrders
                        itemBuilder: (context, index) {
                          final order = viewModel.ownerOrders[index]; // ✅ SỬA 3: Bốc đơn hàng từ mảng ownerOrders ra vẽ UI

                          // Giả lập logic hiển thị khoảng thời gian vừa xong hoặc thời gian đặt đơn
                          String timeAgo = "Vừa xong";
                          if (index == 1) timeAgo = "10 phút trước";
                          if (index == 2) timeAgo = "25 phút trước";
                          if (index > 2) timeAgo = "1 giờ trước";

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFE5E7EB), width: 0.5),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(14),
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "#${order.orderCode}",
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
                                  ),
                                  Text(
                                    timeAgo,
                                    style: const TextStyle(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 14,
                                        backgroundColor: Colors.grey[200],
                                        child: const Icon(Icons.person, size: 16, color: Colors.grey),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        order.receiverName,
                                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 13),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(Icons.calendar_month_outlined, size: 14, color: Colors.grey[500]),
                                      const SizedBox(width: 4),
                                      Text(
                                        "${order.startDate} - ${order.endDate} (${order.rentalDays} ngày)",
                                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  RichText(
                                    text: TextSpan(
                                      text: "Tổng tiền: ",
                                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                      children: [
                                        TextSpan(
                                          text: "${FormatUtils.formatMoney(double.tryParse(order.totalAmount.toString()) ?? 0.0)}đ",
                                          style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 13),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
                              
                              // 🚀 CHÍ MẠNG: Nhấp vào đơn nào, bốc ID đơn đó ném sang trang chi tiết duyệt đơn!
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  '/owner-filter', // Trỏ thẳng đến màn hình chi tiết duyệt đơn có arguments nhận ID
                                  arguments: order.id,
                                );
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}