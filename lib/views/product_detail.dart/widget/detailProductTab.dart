import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentshare_app/models/product_model.dart';
import 'package:rentshare_app/services/chat_service.dart';
import 'package:rentshare_app/utils/format_utils.dart';
import 'package:rentshare_app/viewmodels/auth_viewmodel.dart';
import 'package:rentshare_app/viewmodels/chat_viewmodel.dart';
import 'package:rentshare_app/views/chat/chat.dart'; 

class DetailTab extends StatelessWidget {
  final ProductModel item;

  const DetailTab({super.key, required this.item});

  
  Map<String, dynamic> _getDynamicSpecification() {
    final Map<String, dynamic> specs = Map<String, dynamic>.from(item.specifications);
    
    if (specs.containsKey('RAM')) {
      return {'icon': Icons.memory_rounded, 'value': specs['RAM'].toString()};
    }
    if (specs.containsKey('Sức chứa')) {
      return {'icon': Icons.people_outline_rounded, 'value': specs['Sức chứa'].toString()};
    }
    if (specs.containsKey('Công suất')) {
      return {'icon': Icons.bolt_rounded, 'value': specs['Công suất'].toString()};
    }

    if (specs.containsKey('Dung tích')) {
      return {'icon': Icons.local_drink_outlined, 'value': specs['Dung tích'].toString()};
    }

    if (specs.containsKey('Kích thước')) {
      return {'icon': Icons.straighten_rounded, 'value': specs['Kích thước'].toString()};
    }
    
   
    final cleanKeys = specs.keys.where((k) => k != "Đặc điểm nổi bật").toList();
    if (cleanKeys.isNotEmpty) {
      final firstKey = cleanKeys.first;
      return {'icon': Icons.info_outline_rounded, 'value': specs[firstKey].toString()};
    }
    
    return {'icon': Icons.widgets_outlined, 'value': "Tiêu chuẩn"};
  }

  @override
  Widget build(BuildContext context) {
    const themeColor = Color(0xFF0056D2); 
    double averageRating = 5.0; 
    if (item.reviews.isNotEmpty) {
      final totalRating = item.reviews.map((r) => r.rating).reduce((a, b) => a + b);
      averageRating = totalRating / item.reviews.length;
    }

    
    final dynamicSpec = _getDynamicSpecification();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, height: 1.3)),
          const SizedBox(height: 8),
          Row(children: [
            const Icon(Icons.star_rounded, color: Colors.orange, size: 18), 
            Text(
              " ${averageRating.toStringAsFixed(1)} (${item.reviews.length} đánh giá)", 
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)
            ),
            Text(
              " - Đã thuê ${item.rentedCount} lần", 
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13, color: Colors.grey)
            ),
          ]),
          const SizedBox(height: 15),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9).withValues(alpha: 0.4), 
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFC8E6C9), width: 1),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.gpp_good_outlined, 
                  color: Color(0xFF2E7D32), 
                  size: 24,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(fontSize: 15, color: Colors.black87),
                          children: [
                            const TextSpan(text: "Tiền cọc: ", style: TextStyle(fontWeight: FontWeight.w500)),
                            TextSpan(
                              text: "${FormatUtils.formatMoney(double.parse(item.depositAmount))} đ",
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Hoàn lại 100% nếu không có hư hỏng",
                        style: TextStyle(color: Colors.black54, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20), 
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              backgroundColor: Colors.grey[200],
              backgroundImage: item.ownerAvatar.isNotEmpty ? NetworkImage(item.ownerAvatar) : null,
              child: item.ownerAvatar.isEmpty ? const Icon(Icons.person, color: Colors.grey) : null,
            ),
            title: Row(children: [
              Text(item.ownerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(width: 6),
              const Icon(Icons.verified, color: Colors.blue, size: 14),
            ]),
            subtitle: const Text("Chủ shop Rentshare", style: TextStyle(color: Colors.grey, fontSize: 12)),
            trailing: OutlinedButton.icon(
              onPressed: () async{
                final myId = Provider.of<AuthProvider>(context, listen: false).id ?? 0;
                try{
                  int convId = await ChatService.getOrCreateConversation( item.id, item.ownerId);
                  if (context.mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            conversationId: convId, 
                            myUserId: myId, 
                            shopName: item.ownerName,
                          ),
                        ),
                      ).then((val){
                        Provider.of<ChatViewModel>(context, listen: false).fetchConversations();
                      });
                    }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
                }
              }, 
              icon: const Icon(Icons.chat_bubble_outline, size: 14), 
              label: const Text("Nhắn tin"),
              style: OutlinedButton.styleFrom(
                foregroundColor: themeColor, 
                side: const BorderSide(color: themeColor),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6)
              ),
            ),
          ),
          const SizedBox(height: 10),

        
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(10)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(child: _buildSummaryItem(Icons.category_outlined, item.categoryName)),
                Expanded(
                  child: _buildSummaryItem(
                    Icons.location_on_outlined, 
                    item.location.isNotEmpty ? item.location : "Chưa rõ vị trí",
                  ),
                ),
                Expanded(child: _buildSummaryItem(dynamicSpec['icon'] as IconData, dynamicSpec['value'].toString())),
              ],
            ),
          ),
          const Divider(height: 35, thickness: 0.5),

          if (item.tierPricings.isNotEmpty) ...[
            const Text("Bảng giá thuê theo ngày", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: item.tierPricings.map((tier) {
                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      children: [
                        Text("Thuê ≥ ${tier.minDays} ngày", style: const TextStyle(fontSize: 11, color: Colors.grey)),
                        const SizedBox(height: 4),
                        Text(
                          FormatUtils.formatMoney(tier.pricePerDay), 
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: themeColor)
                        ),
                        const Text("/ngày", style: TextStyle(fontSize: 10, color: Colors.grey)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const Divider(height: 35, thickness: 0.5),
          ],

          const Text("Mô tả sản phẩm", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(item.description, style: const TextStyle(color: Colors.black87, height: 1.5, fontSize: 13.5)),
          
          const Divider(height: 35, thickness: 0.5),
          const Text("Thông tin chi tiết", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          
          ...item.specifications.entries.where((e) => e.key != "Đặc điểm nổi bật").map((e) {
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey[100]!, width: 0.5),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start, 
                children: [
                  SizedBox(width: 120, child: Text(e.key, style: const TextStyle(color: Colors.grey, fontSize: 13.5))),
                  const SizedBox(width: 10),
                  Expanded( 
                    child: Text(
                      e.value.toString(), 
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
                      textAlign: TextAlign.right, 
                    ),
                  ),
                ],
              ),
            );
          }),
          
          const Divider(height: 35, thickness: 0.5),
          const Text("Đặc điểm nổi bật", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          
          if (item.specifications['Đặc điểm nổi bật'] is List)
            ...(item.specifications['Đặc điểm nổi bật'] as List).map((f) {
              final cleanFeature = f.toString().trim(); 
              if (cleanFeature.isEmpty) return const SizedBox.shrink();

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start, 
                  children: [
                    const Icon(Icons.check_circle_rounded, color: Colors.green, size: 18), 
                    const SizedBox(width: 10), 
                    Expanded(
                      child: Text(
                        cleanFeature, 
                        style: const TextStyle(fontSize: 13.5, height: 1.4, color: Colors.black),
                      ),
                    ),
                  ],
                ),
              );
            })
          else
            const Text("Không có đặc điểm nổi bật riêng biệt", style: TextStyle(color: Colors.grey, fontSize: 13)),
            
          const SizedBox(height: 100), 
        ],
      ),
    );
  }

  Widget _buildSummaryItem(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 2, 
          overflow: TextOverflow.ellipsis, 
          style: const TextStyle(fontSize: 11), 
        ),
      ],
    );
  }
}