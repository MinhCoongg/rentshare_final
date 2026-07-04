import 'package:flutter/material.dart';
import 'package:rentshare_app/views/Admin/product_management.dart';
import 'package:rentshare_app/views/Admin/user_manager/user_manager_screen.dart'; 

class NavigationProvider extends ChangeNotifier {
  String _currentRoute = '/product-admin'; 
  String get currentRoute => _currentRoute;

  Widget getSelectedPage() {
    switch (_currentRoute) {
      case '/dashboard': return AdminProductScreen();
      case '/product-admin': return AdminProductScreen();
      case '/users': return const UserManagementScreen();
      default: return AdminProductScreen();
    }
  }

  void changeRoute(String newRoute) {
    _currentRoute = newRoute;
    notifyListeners(); 
  }
}