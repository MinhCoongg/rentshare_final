import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentshare_app/viewmodels/navigation_provider.dart';
import 'package:rentshare_app/views/Admin/sidebar/sidebar.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  bool _isCollapsed = false; 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          AppSidebar(
            isCollapsed: _isCollapsed,
            onToggle: () => setState(() => _isCollapsed = !_isCollapsed),
          ),
          Expanded(
            child: Consumer<NavigationProvider>(
                builder: (context, navProvider, child) {
                  return navProvider.getSelectedPage();
                },
              ),
          ),
        ],
      ),
    );
  }
}