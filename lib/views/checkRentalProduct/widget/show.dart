import 'package:flutter/material.dart';
import 'package:rentshare_app/views/owner/list_rental_product_screen.dart';

class ReportSuccessScreen extends StatelessWidget {
  const ReportSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              const CircleAvatar(
                radius: 40,
                backgroundColor: Color(0xFFE8F5E9),
                child: Icon(Icons.check_circle, color: Color(0xFF2E7D32), size: 60),
              ),
              const SizedBox(height: 24),
              const Text("Đã gửi báo cáo thành công!", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              const Text("Báo cáo tình trạng sản phẩm đã được gửi cho khách hàng. Vui lòng chờ khách hàng phản hồi.", 
                  textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
              
              const SizedBox(height: 32),
              
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Thông tin tiếp theo", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    _infoLine("Khách hàng có 24h để phản hồi về báo cáo của bạn."),
                    _infoLine("Nếu khách đồng ý, hệ thống sẽ tự động trừ phí đền bù và hoàn cọc."),
                    _infoLine("Nếu khách khiếu nại, đơn hàng sẽ chuyển sang trạng thái tranh chấp."),
                  ],
                ),
              ),
              const Spacer(),
              
              // 1. Chỉ giữ lại 1 nút duy nhất này thôi
SizedBox(
  width: double.infinity,
  child: ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF4361EE), 
      padding: const EdgeInsets.symmetric(vertical: 16)
    ),
    onPressed: () {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const OwnerRentalListScreen(), 
        ),
        (route) => route.isFirst, 
      );
      },
      child: const Text("Xem danh sách đơn nghiệm thu", 
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ),
              
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoLine(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: Row(children: [const Icon(Icons.info_outline, size: 16, color: Colors.grey), const SizedBox(width: 8), Expanded(child: Text(text, style: const TextStyle(fontSize: 12)))]),
  );
}