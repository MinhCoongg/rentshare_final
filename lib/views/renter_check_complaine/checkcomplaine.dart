import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentshare_app/models/damageReport.dart'; 
import 'package:rentshare_app/viewmodels/rental_order_viewmodel.dart';
import 'package:rentshare_app/utils/format_utils.dart';

class ChiTietBaoCaoScreen extends StatefulWidget {
  final int orderId;
  final dynamic order;

  const ChiTietBaoCaoScreen({super.key, required this.orderId, required this.order});

  @override
  State<ChiTietBaoCaoScreen> createState() => _ChiTietBaoCaoScreenState();
}

class _ChiTietBaoCaoScreenState extends State<ChiTietBaoCaoScreen> {
  late Future<DamageReport?> _reportFuture;

  @override
  void initState() {
    super.initState();
    _reportFuture = context.read<RentalOrderViewModel>().fetchDamageReportDirect(widget.orderId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text("Chi tiết báo cáo", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: FutureBuilder<DamageReport?>(
        future: _reportFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError || snapshot.data == null) return const Center(child: Text("Không tải được báo cáo!"));

          final report = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Banner nhắc nhở
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.orange.withOpacity(0.05), borderRadius: BorderRadius.circular(8)),
                  child: Row(children: [
                    const Icon(Icons.info_outline, color: Colors.orange, size: 20),
                    const SizedBox(width: 8),
                    const Expanded(child: Text("Vui lòng xem kỹ báo cáo và phản hồi trong vòng 24 giờ.", style: TextStyle(fontSize: 13))),
                  ]),
                ),
                
                _buildSection("Thông tin đơn hàng", [
                  ...widget.order.items.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(children: [
                      ClipRRect(borderRadius: BorderRadius.circular(4), child: Image.network(item.image, width: 50, height: 50, fit: BoxFit.cover)),
                      const SizedBox(width: 10),
                      Expanded(child: Text(item.title, style: const TextStyle(fontWeight: FontWeight.w600))),
                      Text("x${item.quantity}"),
                    ]),
                  )).toList(),
                  const Divider(),
                  Text("${widget.order.startDateFormatted} - ${widget.order.endDateFormatted}", style: TextStyle(color: Colors.grey[600])),
                ]),

                _buildSection("Kết quả nghiệm thu từ shop", [
                  Text(report.title, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 8),
                  Text(report.ownerNote, style: const TextStyle(fontSize: 14)),
                  const SizedBox(height: 12),
                  if (report.evidence != null && report.evidence.isNotEmpty) 
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8), 
                      child: Image.network(
                        'http://192.168.1.17:3001${report.evidence}', 
                        height: 150, 
                        width: double.infinity, 
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const SizedBox();
                        },
                      )
                    ),
                ]),

                _buildSection("Chi tiết phí phát sinh", [
                _rowPrice("Tiền cọc ban đầu", widget.order.depositFee.toString()),
                
  
                _rowPrice("Tiền thuê sản phẩm", "- ${widget.order.rentalFee.toString()}", color: Colors.red[700]),
                _rowPrice("Phí đền bù hư hỏng", "- ${report.compensationAmount.toString()}", color: Colors.red[700]),
                
                const Divider(thickness: 1, height: 24),
                
                _rowPrice(
                  "Số tiền hoàn lại cọc", 
                  (double.parse(widget.order.depositFee) - double.parse(widget.order.rentalFee) - report.compensationAmount - double.parse(widget.order.shippingFee)).toString(), 
                  isTotal: true
                ),
              ]),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff1B8A4B),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () async {
                        bool? confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text("Xác nhận"),
                            content: const Text("Bạn đồng ý với mức phạt này và muốn kết thúc đơn thuê?"),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Hủy")),
                              ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Đồng ý")),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          final viewModel = context.read<RentalOrderViewModel>();
                          final result = await viewModel.acceptDamageReport(widget.orderId);
                          
                          if (!context.mounted) return;

                          if (result['success']) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar( backgroundColor: const Color(0xff1B8A4B), content: Text(result['message'])));
                            Navigator.pop(context); // Quay về trang danh sách
                            context.read<RentalOrderViewModel>().loadMyOrders(); 
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['message'])));
                          }
                        }
                      },
                      child: const Text("ĐỒNG Ý", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.orange),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: () {
                        },
                        child: const Text("KHIẾU NẠI", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 12),
        ...children
      ]),
    );
  }


  Widget _rowPrice(String label, String value, {bool isTotal = false, Color? color}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 14)),
        Text(
          "${FormatUtils.formatMoney(double.tryParse(value.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0)}đ",
          style: TextStyle(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: color ?? (isTotal ? const Color(0xff1B8A4B) : Colors.black),
            fontSize: isTotal ? 16 : 14,
          ),
        ),
      ],
    ),
  );
}
}