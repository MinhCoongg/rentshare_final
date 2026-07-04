import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentshare_app/viewmodels/navigation_provider.dart';

class AppSidebar extends StatelessWidget {
  final bool isCollapsed; 
  final VoidCallback onToggle; 

  const AppSidebar({super.key, required this.isCollapsed, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300), 
      width: isCollapsed ? 70 : 260,
      color: const Color(0xFF1A1C2C),
      child: Column(
        children: [
          // Header Logo
          Container(
            height: 70,
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.home_work_outlined, color: Colors.white, size: 28),
                if (!isCollapsed) ...[
                  const SizedBox(width: 10),
                  const Text("RentShare", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                ]
              ],
            ),
          ),
          
          // Danh sách menu
          Expanded(
            child: ListView(
              children: [
                if (!isCollapsed) _buildSectionTitle("TỔNG QUAN"),
                _buildMenuItem(context, "Dashboard", Icons.dashboard_outlined, '/dashboard'),
                
                if (!isCollapsed) _buildSectionTitle("QUẢN LÝ"),
                _buildMenuItem(context, "Duyệt sản phẩm", Icons.inventory_2_outlined, '/product-admin'),
                _buildMenuItem(context, "Người dùng", Icons.people_outline, '/users'),
              ],
            ),
          ),
          
  
          IconButton(
            icon: Icon(isCollapsed ? Icons.chevron_right : Icons.chevron_left, color: Colors.white),
            onPressed: onToggle,
          ),
        ],
      ),
    );
  }


  Widget _buildMenuItem(BuildContext context, String title, IconData icon, String route) {
    final currentRoute = context.watch<NavigationProvider>().currentRoute;
    final bool isSelected = (currentRoute == route);
    return Tooltip(
      message: isCollapsed ? title : "", 
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        decoration: BoxDecoration(
          color: isSelected ? Colors.deepPurple.withOpacity(0.4) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: ListTile(
          leading: Icon(icon, color: isSelected ? Colors.white : Colors.grey[400]),
          title: isCollapsed ? null : Text(title, style: TextStyle(color: isSelected ? Colors.white : Colors.grey[400])),
          onTap: () => context.read<NavigationProvider>().changeRoute(route),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Text(title, style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}