import 'dart:io';

import 'package:flutter/material.dart';
import 'package:rentshare_app/utils/format_utils.dart';
import 'package:rentshare_app/viewmodels/post_product_viewmodel.dart';

class ProductPreviewWidget extends StatelessWidget {
  final PostProductViewModel vm;

  const ProductPreviewWidget({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
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
                    child: vm.model.images.isNotEmpty
                     ? Image.file(
                      File(vm.model.images[0]),
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
                        "${FormatUtils.formatMoney(vm.model.pricePerDay)} đ / ngày",
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
                    Text(
                      vm.model.title,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.category_outlined, size: 16, color: Colors.orange),
                        const SizedBox(width: 4),
                        // Text(
                        //   vm.categories.firstWhere((c) => c.id == vm.model.categoryId).categoryName,
                        //   style: const TextStyle(color: Colors.grey),
                        // ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start, 
                      children: [
                        const Icon(Icons.location_on, size: 16, color: Colors.redAccent),
                        const SizedBox(width: 4),
                        Expanded( 
                          child: Text(
                            vm.model.location, 
                            style: const TextStyle(color: Colors.grey, fontSize: 13),
                            maxLines: 2, 
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    
                    const Divider(height: 32),
                    const Text("Thông số kỹ thuật", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 0,
                      runSpacing: 16,
                      children: vm.categoryAttributes.map((attr) {
                        double columnWidth = (MediaQuery.of(context).size.width - 64) / 2;
                        return SizedBox(
                          width: columnWidth,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.check_circle_outline, size: 16, color: Colors.blue),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "${attr.attributeName}: ${vm.model.dynamicAttributes[attr.id] ?? 'N/A'}",
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),

                    const Divider(height: 32),

                    const Text("Mô tả", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    Text(vm.model.description, style: const TextStyle(color: Colors.black87, height: 1.5)),

                    const Divider(height: 32),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Chính sách (${vm.model.policies.length})", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const Text("Xem tất cả", style: TextStyle(color: Colors.blue, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...vm.model.policies.take(3).map((policy) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, size: 16, color: Colors.grey),
                          const SizedBox(width: 8),
                          Expanded(child: Text("${policy.type}: ${policy.content}", style: const TextStyle(fontSize: 13))),
                        ],
                      ),
                    )),
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