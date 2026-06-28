import 'dart:io';
import 'package:flutter/material.dart';
import 'package:rentshare_app/utils/format_utils.dart';
import 'package:rentshare_app/viewmodels/post_product_viewmodel.dart';

class ProductPreviewWidget extends StatelessWidget {
  final PostProductViewModel vm;

  const ProductPreviewWidget({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    final model = vm.model;
    String categoryName = vm.categoryName;
    List<dynamic> activeTierPrices = [];
    if (vm.tierPrices.isNotEmpty) {
      activeTierPrices = vm.tierPrices; 
    } else if (model.tierPrices.isNotEmpty) {
      activeTierPrices = model.tierPrices; 
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 15,
                offset: const Offset(0, 5),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    child: model.images.isNotEmpty
                        ? Image.file(
                            File(model.images[0]),
                            height: 250,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            height: 250,
                            width: double.infinity,
                            color: Colors.grey[200],
                            child: const Icon(Icons.image_outlined, size: 50, color: Colors.grey),
                          ),
                  ),
                  Positioned(
                    top: 16,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: const BoxDecoration(
                        color: Color(0xFF1976D2),
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(20), bottomLeft: Radius.circular(20)),
                      ),
                      child: Text(
                        "${FormatUtils.formatMoney(
                          (vm.tierPrices.isNotEmpty)
                              ? (double.tryParse(vm.tierPrices[0]["pricePerDay"].toString()) ?? 0.0)
                              : (model.tierPrices.isNotEmpty ? (double.tryParse(model.tierPrices[0]["pricePerDay"].toString()) ?? 0.0) : 0.0)
                        )} đ / ngày",
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                  ),
                ],
              ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
              
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            model.title,
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(6)),
                          child: const Text("Mới", style: TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.category_outlined, size: 15, color: Colors.orange),
                        const SizedBox(width: 4),
                        Text(
                          categoryName,
                          style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.location_on, size: 15, color: Colors.redAccent),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            model.location.isNotEmpty ? model.location : "Chưa cấu hình địa chỉ kho bãi",
                            style: const TextStyle(color: Colors.grey, fontSize: 13, height: 1.3),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    const Divider(height: 32),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Tiền cọc bảo đảm:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black54)),
                        Text(
                          "${FormatUtils.formatMoney(model.depositAmount)} VND",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1976D2)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text("Bảng giá thuê theo ngày", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87)),
                    const SizedBox(height: 8),
                    
                    if (activeTierPrices.isEmpty)
                      const Text("Chưa cấu hình bảng giá thuê.", style: TextStyle(fontSize: 12, color: Colors.grey))
                    else
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(12)),
                        child: Column(
                          children: activeTierPrices.map((tier) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    tier["minDays"] == 1 ? "- 1 ngày" : "- Từ ${tier["minDays"]} ngày trở lên",
                                    style: const TextStyle(fontSize: 13, color: Colors.black),
                                  ),
                                  Text(
                                    "${FormatUtils.formatMoney(double.tryParse(tier["pricePerDay"].toString()) ?? 0.0)} VND/ngày",
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                    const Divider(height: 32),


                    if (model.features.isNotEmpty && model.features.any((f) => f.trim().isNotEmpty)) ...[
                      const Text("Đặc điểm nổi bật", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 8),
                      Column(
                        children: model.features.where((f) => f.trim().isNotEmpty).map((feature) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              children: [
                                const Icon(Icons.star, size: 14, color: Colors.orangeAccent),
                                const SizedBox(width: 8),
                                Expanded(child: Text(feature, style: const TextStyle(fontSize: 13, color: Colors.black87))),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                      const Divider(height: 32),
                    ],

    
                    if (vm.categoryAttributes.isNotEmpty) ...[
                      const Text("Thông số kỹ thuật", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 0,
                        runSpacing: 14,
                        children: vm.categoryAttributes.map((attr) {
                          double columnWidth = (MediaQuery.of(context).size.width - 64) / 2;
                          return SizedBox(
                            width: columnWidth,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.check_circle_outline, size: 15, color: Colors.blue),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    "${attr.attributeName}: ${model.dynamicAttributes[attr.id] ?? 'N/A'}",
                                    style: const TextStyle(fontSize: 13, color: Colors.black87),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                      const Divider(height: 32),
                    ],

                   
                    const Text("Mô tả sản phẩm", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    Text(
                      model.description.isNotEmpty ? model.description : "Không có mô tả cho sản phẩm này.",
                      style: const TextStyle(color: Colors.black87, height: 1.5, fontSize: 13)
                    ),

                    const Divider(height: 32),

                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Quy tắc & Chính sách thuê (${vm.activePolicies.length})", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const Text("Xem tất cả", style: TextStyle(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...vm.activePolicies.map((policy) {
                      final String pName = policy.type;
                      String pContent = "";
                      switch (pName) {
                        case "Trễ hạn":
                          pContent = "Phí phạt là ${policy.fineValue.toString().replaceAll('.0', '')} ${policy.unit == 'PERCENT' ? '%' : 'VNĐ'}";
                          break;
                          
                      case "Hư hỏng":
                          pContent = "Bồi thường theo mức độ:\n"
                                    "- Hư nhẹ: ${policy.lightDamage?.toInt()}%\n"
                                    "- Hư vừa: ${policy.mediumDamage?.toInt()}%\n"
                                    "- Hư nặng: ${policy.heavyDamage?.toInt()}%";
                          break;
                          
                        case "Hủy đơn":
                          pContent = "Chưa duyệt: Hoàn 100% | Đã duyệt: Không được hủy.";
                          break;
                          
                        case "Mất sản phẩm":
                          pContent = "Đền bù 100% giá trị sản phẩm";
                          break;
                          
                        default:
                          pContent = "Liên hệ chủ shop";
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.info_outline, size: 15, color: Colors.grey),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "$pName: $pContent",
                                style: const TextStyle(fontSize: 13, color: Colors.black87, height: 1.3),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}