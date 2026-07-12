import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentshare_app/models/category_rental_stats.dart';
import 'package:rentshare_app/models/dashboard_model.dart';
import 'package:rentshare_app/models/monthlyData.dart';
import 'package:rentshare_app/utils/format_utils.dart';
import 'package:rentshare_app/viewmodels/dashboard_viewmodel.dart';
import 'package:rentshare_app/views/Admin/utils/star_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardViewModel>().loadDashboardData();
      context.read<DashboardViewModel>().loadTopCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      body: Consumer<DashboardViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading) return const Center(child: CircularProgressIndicator());
          final dashboardData = vm.dashboardData;
          if (dashboardData == null) return const Center(child: Text("Đang tải dữ liệu..."));
          final data = vm.dashboardData!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildStatsGrid(data.stats),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(child: _buildMonthlyRentalChart(data.monthlyOrders)),
                    const SizedBox(width: 20),
                    Expanded(child: _buildRevenueChart(data.monthlyOrders)),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _buildCategoryPieChart(vm.topCategories),
                    ),
                  ],
                )

              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsGrid(DashboardStats stats) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      childAspectRatio: 2.5,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [
          StatCard(title: "Tổng người dùng",count:  stats.totalUsers.toString(),color:  Colors.purple,icon:  Icons.people),
          StatCard(title: "Tổng sản phẩm",count:  stats.totalProducts.toString(),color:  Colors.blue,icon:  Icons.inventory),
          StatCard(title: "Chờ duyệt",count:  stats.pendingProducts.toString(),color:  Colors.orange,icon:  Icons.timer),
          StatCard(title: "Tổng đơn thuê",count:  stats.totalRentals.toString(),color:  Colors.green,icon: Icons.receipt_long),
          StatCard(
            title: "Báo cáo nghiệm thu", 
            count: stats.totalComplains.toString(), 
            color: Colors.redAccent, 
            icon: Icons.report_problem
          ),
          StatCard(
            title: "Doanh thu", 
            count: "${FormatUtils.formatMoney(stats.totalRevenue/1000000 )}M",
            color: Colors.deepPurple, 
            icon: Icons.attach_money
          ),
          StatCard(
            title: "Tổng giao dịch", 
            count: stats.totalTransactions.toString(), 
            color: Colors.teal, 
            icon: Icons.credit_card
          ),
          StatCard(
            title: "Đánh giá trung bình", 
            count: stats.averageRating.toStringAsFixed(1), 
            color: Colors.amber, 
            icon: Icons.star
          ),
      ],
    );
  }

  Widget _buildBarChart(List<MonthlyData> monthlyOrders) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      height: 300,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          barTouchData: BarTouchData(
            enabled: true, 
            touchTooltipData: BarTouchTooltipData(
             getTooltipColor: (group) => Colors.transparent, 
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  rod.toY.toInt().toString(), 
                  const TextStyle(color: Colors.purple, fontWeight: FontWeight.bold),
                );
              },
            ),
          ),
          maxY: (monthlyOrders.map((e) => e.totalRentals).reduce((a, b) => a > b ? a : b).toDouble()) + 5,
          barGroups: monthlyOrders.asMap().entries.map((e) {
            return BarChartGroupData(
              x: e.key,
              barRods: [
                BarChartRodData(
                  toY: e.value.totalRentals.toDouble(),
                  color: Colors.purple,
                  width: 35,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                ),
              ],
              showingTooltipIndicators: [0], 
            );
          }).toList(),
          titlesData: FlTitlesData(
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) => Text(monthlyOrders[value.toInt()].month),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLineChart(List<MonthlyData> monthlyOrders) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      height: 300,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: 30,
          gridData: FlGridData(show: false),
          borderData: FlBorderData(show: false), 
          titlesData: FlTitlesData(
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1, 
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() < 0 || value.toInt() >= monthlyOrders.length) return const Text("");
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(monthlyOrders[value.toInt()].month, style: const TextStyle(fontSize: 10)),
                  );
                },
              ),
            ),
            
            // 3. Cấu hình trục Y (Doanh thu)
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 10,
                reservedSize: 40,
                getTitlesWidget: (value, meta) => Text("${value.toInt()}M"), 
              ),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: monthlyOrders.asMap().entries.map((e) {
                return FlSpot(e.key.toDouble(), e.value.totalRevenue / 1000000);
              }).toList(),
              isCurved: true,
              color: Colors.blueAccent,
              barWidth: 4,
              belowBarData: BarAreaData(show: true, color: Colors.blueAccent.withOpacity(0.2)),
              dotData: const FlDotData(show: true), 
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyRentalChart(List<MonthlyData> monthlyOrders) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Số đơn thuê theo tháng", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(height: 250, child: _buildBarChart(monthlyOrders)),
        ],
      ),
    );
  }

  Widget _buildRevenueChart(List<MonthlyData> monthlyOrders) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Doanh thu theo tháng", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(height: 250, child: _buildLineChart(monthlyOrders)), 
        ],
      ),
    );
  }

  Widget _buildCategoryPieChart(List<CategoryRentalStats> stats) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Top danh mục được thuê", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 20),
          Row(
            children: [
              // Phần biểu đồ tròn
              SizedBox(
                height: 150, width: 150,
                child: PieChart(
                  PieChartData(
                    sections: stats.asMap().entries.map((e) {
                      return PieChartSectionData(
                        value: e.value.rentalCount.toDouble(),
                        color: _getCategoryColor(e.key), // Hàm lấy màu cho từng lát
                        radius: 50,
                        showTitle: false,
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  children: stats.asMap().entries.map((e) {
                    return _buildLegendItem(e.value, e.key); 
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(CategoryRentalStats item, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(color: _getCategoryColor(index), shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text(item.categoryName, style: const TextStyle(fontSize: 12)),
          const Spacer(),
          Text("${item.rentalCount}", style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Color _getCategoryColor(int index) {
    List<Color> colors = [
      Colors.purple,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.red,
      Colors.teal,
    ];
    return colors[index % colors.length];
  }
}