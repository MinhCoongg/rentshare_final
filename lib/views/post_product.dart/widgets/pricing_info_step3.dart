import 'package:flutter/material.dart';
import 'package:rentshare_app/utils/currency_format.dart'; 
import 'package:rentshare_app/utils/format_utils.dart'; 
import 'package:rentshare_app/viewmodels/post_product_viewmodel.dart';
import 'package:rentshare_app/views/post_product.dart/widgets/common_widget.dart';

class Step3PricingInfo extends StatelessWidget {
  final PostProductViewModel vm;

  const Step3PricingInfo({super.key, required this.vm});

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
                "3. Giá thuê", 
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)
              ),
              const SizedBox(height: 20),

              CustomTextField(
                key: const ValueKey("deposit_amount_field"),
                label: "Tiền cọc (đặt trước)", 
                hint: "10.000.000",
                suffix: "VND", 
                keyboardType: TextInputType.number,
                initialValue: vm.model.depositAmount > 0 
                    ? FormatUtils.formatMoney(vm.model.depositAmount)
                    : "",
                inputFormatters: [CurrencyInputFormatter()], 
                onChanged: (v) => vm.updateDepositAmount(v.replaceAll('.', '')),
              ),
              const SizedBox(height: 6),
              Text(
                "Khoản tiền cọc sẽ được hoàn lại cho người thuê sau khi trả sản phẩm đúng tình trạng.", 
                style: TextStyle(color: Colors.grey[500], fontSize: 12, height: 1.3, fontWeight: FontWeight.w500)
              ),
              const SizedBox(height: 24),

              Container(height: 1, color: Colors.grey[200]),
              const SizedBox(height: 20),
              const Text(
                "Bảng giá thuê theo ngày ", 
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)
              ),
              const SizedBox(height: 4),
              Text(
                "Thiết lập giá thuê theo số ngày (càng thuê lâu, giá càng ưu đãi)", 
                style: TextStyle(color: Colors.grey[500], fontSize: 12, fontWeight: FontWeight.w500)
              ),
              const SizedBox(height: 20),

              const Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: Text("Số ngày thuê tối thiểu", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54)),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    flex: 5,
                    child: Text("Giá thuê mỗi ngày (VND)", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54)),
                  ),
                  SizedBox(width: 40),
                ],
              ),
              const SizedBox(height: 8),

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: vm.tierPrices.length,
                itemBuilder: (context, index) {
                  final tier = vm.tierPrices[index];
                  
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 4,
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                            initialValue: tier["minDays"].toString(),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.grey[50],
                              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF1976D2), width: 1.5)),
                            ),
                            onChanged: (v) {
                              vm.updateTierPriceValue(index, minDays: int.tryParse(v) ?? 1);
                            },
                          ),
                        ),
                        const SizedBox(width: 12),

                        Expanded(
                          flex: 5,
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                            initialValue: tier["pricePerDay"] > 0 
                                ? FormatUtils.formatMoney(tier["pricePerDay"])
                                : "",
                            inputFormatters: [CurrencyInputFormatter()],
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.grey[50],
                              hintText: "500.000",
                              hintStyle: TextStyle(color: Colors.grey[400]),
                              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF1976D2), width: 1.5)),
                            ),
                            onChanged: (v) {
                              final rawPrice = double.tryParse(v.replaceAll('.', '')) ?? 0.0;
                              vm.updateTierPriceValue(index, pricePerDay: rawPrice);
                            },
                          ),
                        ),

                        SizedBox(
                          width: 40,
                          child: index == 0
                              ? const SizedBox()
                              : IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.grey, size: 22),
                                  onPressed: () => vm.removeTierPrice(index),
                                ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  side: BorderSide(color: Colors.grey[300]!),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  backgroundColor: Colors.white,
                ),
                onPressed: () => vm.addTierPrice(),
                icon: const Icon(Icons.add, size: 18, color: Colors.black87),
                label: const Text(
                  "Thêm mức giá", 
                  style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 14)
                ),
              ),
            ],
          ),
        ),
      ],
    );
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