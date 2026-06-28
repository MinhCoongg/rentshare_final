import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentshare_app/models/user_model.dart';
import 'package:rentshare_app/utils/format_utils.dart';
import 'package:rentshare_app/viewmodels/home_viewmodel.dart';
import 'package:rentshare_app/viewmodels/login_viewmodel.dart';
import 'package:rentshare_app/viewmodels/rental_order_viewmodel.dart';
import 'package:rentshare_app/views/addUpdateAddress/address.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final loginVm = context.read<LoginViewModel>();
      if (loginVm.currentUser == null) {
        await loginVm.checkLoggedInStatus();
      }
      context.read<RentalOrderViewModel>().loadMyOrders();
    });
  }
  

  @override
  Widget build(BuildContext context) {
    final loginVm = context.watch<LoginViewModel>();
    final user = loginVm.currentUser;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Cá nhân", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [

            _buildProfileHeader(user),
            const SizedBox(height: 10),
            
            _buildWalletSection(user),
            const SizedBox(height: 10),
            
            _buildOrderSection(context),
            const SizedBox(height: 10),
            

            _buildMenuSection(),
            
            const SizedBox(height: 20),
            

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.red,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: ()async{
                  await loginVm.logout();
                  Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                },
                child: const Text("Đăng xuất", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(UserModel? user) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.grey[200], 
            backgroundImage: (user?.avatar != null && user!.avatar.isNotEmpty)
                ? NetworkImage('http://192.168.1.17:3001${user.avatar}')
                : null, 
            child: (user?.avatar == null || user!.avatar.isEmpty)
                ? const Icon(Icons.person, size: 40, color: Colors.grey) 
                : null,
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(user?.name ?? "Người dùng", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(user?.email ?? "" , style: TextStyle(color: Colors.blue, fontSize: 12)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildWalletSection(UserModel? user) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text("Ví của tôi", style: TextStyle(fontWeight: FontWeight.bold)),
            Text("${FormatUtils.formatMoney(user?.wallet.balance ?? 0)}đ", 
              style: const TextStyle(fontSize: 18, color: Colors.blue, fontWeight: FontWeight.bold)),
          ]),
          OutlinedButton(onPressed: () {}, child: const Text("Nạp tiền")),
        ],
      ),
    );
  }

  Widget _buildOrderSection(BuildContext context) {
    final orderVm = context.watch<RentalOrderViewModel>();
    final List<Map<String, dynamic>> items = [
      {'icon': Icons.assignment_outlined, 'label': 'Chờ duyệt', 'status': 'Pending'},
      {'icon': Icons.local_shipping_outlined, 'label': 'Đang giao', 'status': 'Shipping'},
      {'icon': Icons.inventory_2_outlined, 'label': 'Đang thuê', 'status': 'Delivered'},
      {'icon': Icons.assignment_return_outlined, 'label': 'Nghiệm thu', 'status': 'Inspecting'},
      {'icon': Icons.check_circle_outline, 'label': 'Hoàn tất', 'status': 'Completed'},
      {'icon': Icons.cancel_outlined, 'label': 'Đã hủy', 'status': 'Cancelled'},
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: items.map((item) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: _buildOrderItem(
              item['icon'], 
              item['label'], 
              orderVm.getCountByStatus(item['status']), 
              () {
                Navigator.pushNamed(context, '/my-order', arguments: item['status']).then((_) {
                  context.read<RentalOrderViewModel>().loadMyOrders();
                });
}
            ),
          )).toList(),
        ),
      ),
    );
  }

  Widget _buildOrderItem(IconData icon, String label, int count, VoidCallback onTap) {
    return InkWell( 
      onTap: onTap, 
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          children: [
            Badge(
              isLabelVisible: count > 0,
              label: Text(count.toString()),
              child: Icon(icon, size: 28, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 11, color: Colors.black87)),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          _buildMenuItem(Icons.inventory_outlined, "Sản phẩm của tôi", "Quản lý sản phẩm cho thuê", () {}),
          _buildMenuItem(
            Icons.verified_user_outlined, 
            "Duyệt sản phẩm", 
            "Duyệt hoặc từ chối sản phẩm", 
            () async {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => const Center(child: CircularProgressIndicator()),
              );
              final hasProduct = await context.read<HomeViewModel>().hasAnyProduct();
              Navigator.pop(context);
              if (hasProduct) {
                Navigator.pushNamed(context, '/owner-orders-list');
              } else {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Thông báo"),
                    content: const Text("Bạn chưa có sản phẩm nào đang cho thuê. Hãy đăng sản phẩm đầu tiên để bắt đầu quản lý nhé!"),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/post_product'); 
                        },
                        child: const Text("Đăng sản phẩm"),
                      ),
                    ],
                  ),
                );
              }
            }
          ),
          _buildMenuItem(
            Icons.location_on_outlined, 
            "Địa chỉ của tôi", 
            "Quản lý địa chỉ nhận hàng", 
            () {
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => AddressSelectionScreen()),
              );
            }
          ),
          _buildMenuItem(Icons.payment_outlined, "Phương thức thanh toán", "Tài khoản và thẻ ngân hàng", () {}),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
      onTap: onTap,
    );
  }
}