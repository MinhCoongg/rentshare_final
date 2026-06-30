import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentshare_app/viewmodels/rental_order_viewmodel.dart';
import 'package:rentshare_app/views/myorder/widget/cardInforProduct.dart';
import 'package:rentshare_app/views/renter_check_complaine/checkcomplaine.dart';

class MyRentalsScreen extends StatefulWidget {
  const MyRentalsScreen({super.key});

  @override
  State<MyRentalsScreen> createState() => _MyRentalsScreenState();
}

class _MyRentalsScreenState extends State<MyRentalsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<Map<String, String>> _tabs = [
    {'title': 'Tất cả', 'status': ''},
    {'title': 'Chờ duyệt', 'status': 'Pending'},
    {'title': 'Đang giao', 'status': 'Shipping'},
    {'title': 'Đang thuê', 'status': 'Delivered'}, 
    {'title': 'Chờ trả', 'status': 'Returned'}, 
    {'title': 'Nghiệm thu', 'status': 'Inspecting'},
    {'title': 'Đã hoàn tất', 'status': 'Completed'},
    {'title': 'Đã hủy', 'status': 'Cancelled'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _fetchOrders();
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleInitialStatus();
    });

  }

  void _fetchOrders() {
    final String currentStatus = _tabs[_tabController.index]['status']!;
    context.read<RentalOrderViewModel>().loadMyOrders(
          status: currentStatus,
        );
  }

  void _handleInitialStatus() {
    final String? initialStatus = ModalRoute.of(context)?.settings.arguments as String?;
    
    if (initialStatus != null && initialStatus.isNotEmpty) {
      int index = _tabs.indexWhere((tab) => tab['status'] == initialStatus);
      if (index != -1) {
        _tabController.index = index;
      }
    }
    _fetchOrders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Đơn thuê của tôi",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: const Stack(
              children: [
                Icon(Icons.notifications_none_outlined, color: Colors.black, size: 28),
                Positioned(
                  right: 0,
                  top: 0,
                  child: CircleAvatar(
                    radius: 7,
                    backgroundColor: Colors.red,
                    child: Text("3", style: TextStyle(color: Colors.white, fontSize: 9)),
                  ),
                )
              ],
            ),
            onPressed: () {},
          )
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: const Color(0xff1B8A4B),
          labelColor: const Color(0xff1B8A4B),
          unselectedLabelColor: Colors.grey[600],
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
          tabs: _tabs.map((tab) => Tab(text: tab['title'])).toList(),
        ),
      ),
      body: Consumer<RentalOrderViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFE07A5F)),
            );
          }

          if (viewModel.myOrders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 12),
                  Text("Không có đơn hàng nào ở mục này!", style: TextStyle(color: Colors.grey[600], fontSize: 15)),
                ],
              ),
            );
          }


          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: viewModel.myOrders.length,
            itemBuilder: (context, index) {
              final order = viewModel.myOrders[index];
              return RentalOrderCard(
                order: order,
                onDetailPressed: () async {
                  if (order.status == 'Inspecting') {
                    Navigator.of(context, rootNavigator: true).push(
                      MaterialPageRoute(
                        builder: (_) => ChiTietBaoCaoScreen(
                          orderId: order.id, // Truyền ID
                          order: order,      // Truyền đối tượng order
                        ),
                      ),
                    );
                  } 

                  else {
                    Navigator.of(context, rootNavigator: true).pushNamed('/rental-detail', arguments: order.id);
                  }
                },
                onContactPressed: () {
                  // Logic chat 
                },
              );
            },
          );
        },
      ),
    );
  }

  
  
}