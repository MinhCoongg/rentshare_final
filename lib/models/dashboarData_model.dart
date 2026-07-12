import 'package:rentshare_app/models/dashboard_model.dart';
import 'package:rentshare_app/models/monthlyData.dart';

class DashboardData {
  final DashboardStats stats;
  final List<MonthlyData> monthlyOrders;

  DashboardData({required this.stats, required this.monthlyOrders});

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      stats: DashboardStats.fromJson(json['stats']), 
      monthlyOrders: (json['monthlyOrders'] as List)
          .map((e) => MonthlyData.fromJson(e)).toList(),
    );
  }
}