import 'package:flutter/material.dart';
import 'package:rentshare_app/models/damageReport.dart';
import 'package:rentshare_app/utils/format_utils.dart';


class ChiTietBaoCaoScreen extends StatelessWidget {
  final DamageReport report;
  final dynamic order; 

  const ChiTietBaoCaoScreen({super.key, required this.report, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Chi tiết báo cáo")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Banner nhắc nhở
            Container(
              padding: const EdgeInsets.all(12),
              color: Colors.orange.withOpacity(0.1),
              child: const Text("Vui lòng xem kỹ báo cáo và phản hồi trong vòng 24 giờ."),
            ),
            
            _buildSection("Thông tin đơn hàng", [
              Text(order.productName, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text("${order.startDate} - ${order.endDate}"),
            ]),

           
            _buildSection("Kết quả nghiệm thu từ shop", [
              Text(report.title, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              Text(report.ownerNote),
              const SizedBox(height: 10),
              
              Row(children: [
                 Expanded(child: Image.network(report.evidence, height: 80, fit: BoxFit.cover)),
              ]),
            ]),

            // Chi tiết phí
            _buildSection("Chi tiết phí phát sinh", [
              _rowPrice("Tiền thuê", order.rentalFee),
              _rowPrice("Phí đền bù", report.compensationAmount.toString()),
              const Divider(),
              _rowPrice("Số tiền hoàn cho bạn", (order.depositFee - report.compensationAmount).toString(), isTotal: true),
            ]),

            // Nút bấm
            Row(
              children: [
                Expanded(child: OutlinedButton(onPressed: () {}, child: const Text("Liên hệ shop"))),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                    onPressed: () {
                       
                    },
                    child: const Text("Phản hồi ngay", style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Card(
      margin: const EdgeInsets.only(top: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const Divider(),
          ...children
        ]),
      ),
    );
  }

  Widget _rowPrice(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(label), Text("${FormatUtils.formatMoney(double.parse(value))}đ", 
          style: TextStyle(fontWeight: isTotal ? FontWeight.bold : FontWeight.normal))],
      ),
    );
  }
}