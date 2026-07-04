import 'package:flutter/material.dart';
import 'package:rentshare_app/views/chat/conversation.dart';
import 'package:rentshare_app/views/home_product/homeProduct.dart';
import 'package:rentshare_app/views/post_product.dart/post_product_screen.dart';
import 'package:rentshare_app/views/profile/profile.dart';


class MainScreen extends StatefulWidget {
  final int initialIndex;
  const MainScreen({super.key, this.initialIndex = 0,});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }
  
  final List<Widget> _pages = const [
    HomePage(),
    HomePage(),
    PostProductScreen(),
    ChatListScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        height: 65,
        backgroundColor: Colors.white,
        elevation: 10,
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) {
          setState(() => _selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: "Trang chủ"),
          NavigationDestination(icon: Icon(Icons.grid_view_outlined), selectedIcon: Icon(Icons.grid_view), label: "Sản phẩm"),
          NavigationDestination(icon: Icon(Icons.add_circle_outline), selectedIcon: Icon(Icons.add_circle), label: "Đăng SP"),
          NavigationDestination(icon: Icon(Icons.message_outlined), selectedIcon: Icon(Icons.receipt_long), label: "Tin nhắn"),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: "Cá nhân"),
        ],
      ),
    );
  }
}