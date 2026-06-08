import 'package:flutter/material.dart';
import 'package:rentshare_app/viewmodels/post_product_viewmodel.dart';
import 'package:rentshare_app/views/post_product.dart/widgets/common_widget.dart';

class Step2ProductDetail extends StatelessWidget {
  final PostProductViewModel vm;

  const Step2ProductDetail({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      children: [
        _buildPremiumCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "2. Chi tiết sản phẩm", 
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)
              ),
              const SizedBox(height: 10),
              
              ...vm.categoryAttributes.map((attr) {
                final String name = attr.attributeName.trim();
                return Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: CustomTextField(
                    key: ValueKey("attr_${attr.id}"), 
                    label: "$name *",
                    hint: _getHintText(name),
                    initialValue: vm.model.dynamicAttributes[attr.id] ?? "",
                    onChanged: (v) => vm.updateAttribute(attr.id, v),
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  
  String _getHintText(String attrName) {
    if (attrName.contains("Kích thước")) return "Ví dụ: 210 x 210 x 130 cm";
    if (attrName.contains("Trọng lượng")) return "Ví dụ: 3.5 kg";
    if (attrName.contains("Chất liệu")) return "Ví dụ: Vải Polyester 210D";
    if (attrName.contains("Chống nước")) return "Ví dụ: PU3000 mm";
    return "Nhập ${attrName.toLowerCase()}";
  }

  Widget _buildPremiumCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: child,
    );
  }
}