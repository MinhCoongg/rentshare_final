import 'package:flutter/material.dart';
import 'package:rentshare_app/viewmodels/post_product_viewmodel.dart';
import 'package:rentshare_app/views/post_product.dart/widgets/common_widget.dart';

class Step2ProductDetail extends StatefulWidget {
  final PostProductViewModel vm;
  const Step2ProductDetail({super.key, required this.vm});

  @override
  State<Step2ProductDetail> createState() => _Step2ProductDetailState();
}

class _Step2ProductDetailState extends State<Step2ProductDetail> {
  @override
  void initState() {
    super.initState();
    widget.vm.loadUnitsForAttributes(widget.vm.categoryAttributes);
  }
  @override
  Widget build(BuildContext context) {
    final vm = widget.vm;
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
                final units = vm.getUnitsForAttribute(attr.id);

                return Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (units.isNotEmpty) ...[
                        Text("$name *", style: const TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        Row(
                           crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 2,
                              child: CustomTextField(
                                key: ValueKey("attr_val_${attr.id}"),
                                label: "", 
                                hint: "Nhập số",
                                keyboardType: TextInputType.number,
                                initialValue: vm.attributeValues[attr.id] ?? "",
                                onChanged: (v) => vm.updateAttributeValue(attr.id, v),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                            flex: 1,
                            child: SizedBox(
                              height: 56,
                              child: DropdownButtonFormField<int>(
                                value: vm.selectedUnits[attr.id],
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.grey[50],
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(color: Colors.grey.shade300),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(color: Color(0xFF1976D2)),
                                  ),
                                ),
                                hint: const Text("Đơn vị"),
                                isExpanded: true,
                                items: units.map((unit) {
                                  return DropdownMenuItem<int>(
                                    value: unit.id,
                                    child: Text(unit.unitName),
                                  );
                                }).toList(),
                                onChanged: (unitId) {
                                  setState(() {
                                    vm.updateAttributeUnit(attr.id, unitId!);
                                  });
                                },
                              ),
                            ),
                          ),
                          ],
                        ),
                      ] 
                      else ...[
                        CustomTextField(
                          key: ValueKey("attr_${attr.id}"),
                          label: "$name *",
                          hint: _getHintText(name),
                          initialValue: vm.attributeValues[attr.id] ?? "",
                          onChanged: (v) => vm.updateAttributeValue(attr.id, v),
                        ),
                      ],
                    ],
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