import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentshare_app/utils/dialog_confirm.dart';
import 'package:rentshare_app/viewmodels/user_viewmodel.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserViewModel>().loadUsers();
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
            flex: 3,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  _buildStatsRow(),
                  const SizedBox(height: 24),
                  _buildFilterBar(),
                  const SizedBox(height: 16),
                  _buildUserTable(),
                ],
              ),
            ),
          ),
         
        ],
      ),
    );
  }

  // 1. Thống kê
  Widget _buildStatsRow() {
  return Consumer<UserViewModel>(builder: (context, vm, _) {
    return Row(
      children: [
        _statCard("Tổng người dùng", vm.stats['totalUsers']?.toString() ?? '0', Colors.purple, Icons.people),
        _statCard("Chủ cho thuê", vm.stats['ownerUsers']?.toString() ?? '0', Colors.green, Icons.business_center),
        _statCard("Quản trị viên", vm.stats['adminUsers']?.toString() ?? '0', Colors.orange, Icons.admin_panel_settings),
      ],
    );
  });
}

  Widget _statCard(String title, String count, Color color, IconData icon) { 
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: Row( 
          children: [
            Icon(icon, size: 40, color: color.withOpacity(0.5)),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(count, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
                Text(title, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 2. Thanh lọc & tìm kiếm
  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: const InputDecoration(hintText: "Tìm kiếm tên, email...", prefixIcon: Icon(Icons.search), border: OutlineInputBorder()),
              onChanged: (val) => context.read<UserViewModel>().searchUsers(val),
            ),
          ),
          const SizedBox(width: 16),
          Consumer<UserViewModel>(builder: (context, vm, _) {
            final String currentValue = vm.selectedStatus.isEmpty ? '' : vm.selectedStatus;
            return DropdownButton<String>(
              value: currentValue,
              items: [
                const DropdownMenuItem(value: '', child: Text('Tất cả')), 
                const DropdownMenuItem(value: 'Active', child: Text('Hoạt động')),
                const DropdownMenuItem(value: 'Blocked', child: Text('Bị khóa')),
              ].toList(),
              onChanged: (val) => vm.filterByStatus(val ?? ''),
            );
          }),
        ],
      ),
    );
  }

  // 3. Bảng dữ liệu
  Widget _buildUserTable() {
    return Container(
      color: Colors.white,
      child: Consumer<UserViewModel>(builder: (context, vm, _) {
        if (vm.isLoading) return const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()));
        return DataTable(
          columns: const [
            DataColumn(label: Text('NGƯỜI DÙNG')),
            DataColumn(label: Text('SỐ ĐIỆN THOẠI')),
            DataColumn(label: Text('EMAIL')),
            DataColumn(label: Text('TRẠNG THÁI')),
            DataColumn(label: Text('THAO TÁC')),
          ],
          rows: vm.users.map((user) => DataRow(cells: [
            DataCell(
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundImage: NetworkImage('http://192.168.1.17:3001${user.avatar}') 
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text("ID: #USRS${user.id.toString().padLeft(2, '0')}", style: const TextStyle(fontSize: 10, color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),
            DataCell(Text(user.phoneNumber ?? 'Chưa cập nhật SDT')),
            DataCell(Text(user.email)),
            DataCell(Chip(
              label: Text(user.isBlocked ? "Bị khóa" : "Hoạt động"),
              backgroundColor: user.isBlocked ? Colors.red.shade100 : Colors.green.shade100,
            )),
            DataCell(
              IconButton(
                icon: Icon(user.isBlocked ? Icons.lock_open : Icons.lock, 
                          color: user.isBlocked ? Colors.red : Colors.green),
                onPressed: () async {
                  String action = user.isBlocked ? "mở khóa" : "khóa";
                  bool confirmed = await DifferentShopDialog.show(
                    context: context,
                    title: "Xác nhận $action người dùng",
                    content: "Bạn có chắc chắn muốn ${user.isBlocked ? 'mở khóa' : 'khóa'} tài khoản của ${user.name} không?",
                    actionButtonText: "Đồng ý",
                  );
                  if (confirmed) {
                    await vm.toggleUserStatus(user);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Đã $action thành công người dùng ${user.name}!"),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
              ),
            ),
          ])).toList(),
        );
      }),
    );
  }

  // 4. Sidebar phải
}