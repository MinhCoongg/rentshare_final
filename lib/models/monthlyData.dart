class MonthlyData {
  final String month;
  final int totalRentals;
  final double totalRevenue;

  MonthlyData({required this.month, required this.totalRentals, required this.totalRevenue});

  factory MonthlyData.fromJson(Map<String, dynamic> json) {
    return MonthlyData(
      month: json['month'],
      totalRentals: json['totalRentals'] ?? 0,
      totalRevenue: double.parse(json['totalRevenue'].toString()),
    );
  }
}