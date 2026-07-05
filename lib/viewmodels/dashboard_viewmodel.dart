import 'package:flutter/material.dart';
import 'package:rentshare_app/models/category_rental_stats.dart';
import 'package:rentshare_app/models/dashboarData_model.dart';
import 'package:rentshare_app/services/dashboard_service.dart';

class DashboardViewModel extends ChangeNotifier {
  DashboardData? _dashboardData;
  bool _isLoading = false;
  String? _errorMessage;
  List<CategoryRentalStats> _topCategories = [];
  List<CategoryRentalStats> get topCategories => _topCategories;
  DashboardData? get dashboardData => _dashboardData;
  bool get isLoading => _isLoading;

  Future<void> loadDashboardData() async {
    _isLoading = true;
    notifyListeners();

    try {
      _dashboardData = await DashboardService.fetchDashboardData();
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint("Lỗi: $_errorMessage");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }



  Future<void> loadTopCategories() async {
    _isLoading = true;
    notifyListeners(); 

    try {
      _topCategories = await DashboardService.fetchTopCategories();
    } catch (e) {
      debugPrint("Lỗi load top categories: $e");
    } finally {
      _isLoading = false;
      notifyListeners(); 
    }
  }
}