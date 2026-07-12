class DashboardStats {
  final int totalUsers;
  final int totalProducts;
  final int pendingProducts;
  final int totalRentals;
  final int totalComplains;
  final double totalRevenue;
  final int totalTransactions;
  final double averageRating;

  DashboardStats({
    required this.totalUsers,
    required this.totalProducts,
    required this.pendingProducts,
    required this.totalRentals,
    required this.totalComplains,
    required this.totalRevenue,
    required this.totalTransactions,
    required this.averageRating,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalUsers: json['totalUsers'] ?? 0,
      totalProducts: json['totalProducts'] ?? 0,
      pendingProducts: json['pendingProducts'] ?? 0,
      totalRentals: json['totalRentals'] ?? 0,
      totalComplains: json['totalComplains'] ?? 0,
      totalRevenue: double.parse(json['totalRevenue'].toString()),
      totalTransactions: json['totalTransactions'] ?? 0,
      averageRating: double.parse(json['averageRating'].toString()),
    );
  }
}