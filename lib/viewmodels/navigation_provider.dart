import 'package:flutter/material.dart';
import 'package:rentshare_app/views/Admin/RentalManagement/RentalManagementScreen.dart';
import 'package:rentshare_app/views/Admin/dashboard/dashboard_screen.dart';
import 'package:rentshare_app/views/Admin/product_management.dart';
import 'package:rentshare_app/views/Admin/user_manager/user_manager_screen.dart'; 

class NavigationProvider extends ChangeNotifier {
  String _currentRoute = '/dashboard'; 
  String get currentRoute => _currentRoute;

  Widget getSelectedPage() {
    switch (_currentRoute) {
      case '/dashboard': return DashboardScreen();
      case '/product-admin': return AdminProductScreen();
      case '/users': return const UserManagementScreen();
      case '/orders' : return const RentalManagementScreen();
      default: return DashboardScreen();
    }
  }

  void changeRoute(String newRoute) {
    _currentRoute = newRoute;
    notifyListeners(); 
  }
}