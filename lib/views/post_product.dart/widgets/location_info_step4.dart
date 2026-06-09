import 'package:flutter/material.dart';
import 'package:rentshare_app/models/address_model.dart';
import 'package:rentshare_app/viewmodels/post_product_viewmodel.dart';
import 'package:rentshare_app/views/post_product.dart/widgets/formAddress.dart';

class Step4LocationInfo extends StatefulWidget {
  final PostProductViewModel vm;
  const Step4LocationInfo({super.key, required this.vm});

  @override
  State<Step4LocationInfo> createState() => _Step4LocationInfoState();
}

class _Step4LocationInfoState extends State<Step4LocationInfo> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.vm.loadUserAddressBook();
    });

    if (widget.vm.model.features.isEmpty) {
      widget.vm.model.features.add("");
    }
  }

  void _showAddressBookBottomSheet(BuildContext context, PostProductViewModel vm) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.8,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Sổ địa chỉ kho bãi của bạn",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.grey, size: 20),
                        onPressed: () => Navigator.pop(context),
                      )
                    ],
                  ),
                  const SizedBox(height: 10),

                  if (vm.isLoadingAddress)
                    const Expanded(
                      child: Center(child: CircularProgressIndicator(color: Color(0xFF1976D2))),
                    )
                  else if (vm.userAddressBook.isEmpty)
                    Expanded(
                      child: Center(
                        child: Text(
                          "Sổ địa chỉ trống trơn!\nHãy tạo địa chỉ kho bãi để đăng bài nhé.",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey[400], fontSize: 13, height: 1.4),
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: vm.userAddressBook.length,
                        itemBuilder: (context, index) {
                          final AddressModel addr = vm.userAddressBook[index];
                          final int currentId = addr.id ?? 0;
                          final bool isSelected = vm.model.addressId == currentId;

                          return InkWell(
                            onTap: () {
                              vm.selectAddressFromBook(currentId, addr.fullAddress);
                              Navigator.pop(context); 
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFF1976D2).withOpacity(0.02) : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected ? const Color(0xFF1976D2) : Colors.grey[200]!,
                                  width: isSelected ? 1.5 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                                    color: isSelected ? const Color(0xFF1976D2) : Colors.grey,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(addr.receiverName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
                                            if (addr.isDefault) ...[
                                              const SizedBox(width: 6),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                                decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(4)),
                                                child: const Text("Mặc định", style: TextStyle(color: Colors.blue, fontSize: 9, fontWeight: FontWeight.bold)),
                                              )
                                            ]
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(addr.fullAddress, style: TextStyle(color: Colors.grey[600], fontSize: 12, height: 1.3)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = widget.vm;

    String currentLabel = "Địa chỉ kho";
    for (var addr in vm.userAddressBook) {
      if (addr.id == vm.model.addressId) {
        currentLabel = addr.receiverName;
      }
    }

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      children: [
        _buildPremiumCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const Row(
                children: [
                  Text("Địa chỉ kho / nơi lưu sản phẩm", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black)),
                  Text(" *", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 12),
              
              InkWell(
                onTap: () => _showAddressBookBottomSheet(context, vm),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.green[50],
                        child: const Icon(Icons.location_on_outlined, color: Colors.green, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(currentLabel, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87)),
                            const SizedBox(height: 4),
                            Text(
                              vm.model.location.isNotEmpty ? vm.model.location : "Đang tải dữ liệu địa chỉ...",
                              style: TextStyle(color: Colors.grey[600], fontSize: 13, height: 1.3),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.unfold_more, color: Colors.black54, size: 20), // Biểu tượng báo hiệu bấm vào để bung lựa chọn
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
            
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 46),
                  side: BorderSide(color: Colors.blue[50]!),
                  backgroundColor: const Color(0xFFF5F9FF),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AddAddressDialog(vm: vm), 
                  );
                }, 
                icon: const Icon(Icons.add, size: 16, color: Color(0xFF1976D2)),
                label: const Text(
                  "Thêm địa chỉ khác", 
                  style: TextStyle(color: Color(0xFF1976D2), fontWeight: FontWeight.bold, fontSize: 13)
                ),
              ),
              const SizedBox(height: 24),
              Container(height: 1, color: Colors.grey[100]),
              const SizedBox(height: 20),

              const Row(
                children: [
                  Text("Đặc điểm nổi bật của sản phẩm", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black)),
                  Text(" *", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                "Nêu những điểm nổi bật giúp sản phẩm của bạn thu hút người thuê.",
                style: TextStyle(color: Colors.grey[500], fontSize: 12, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: vm.model.features.length,
                itemBuilder: (context, index) {
                  final featureText = vm.model.features[index];
                  
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(color: Colors.blue[50], shape: BoxShape.circle),
                          child: Icon(_getFeatureIcon(index), color: const Color(0xFF1976D2), size: 18),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            key: ValueKey("feat_$index"),
                            initialValue: featureText,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.grey[50],
                              hintText: _getHintExample(index),
                              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
                              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey[200]!)),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF1976D2), width: 1.5)),
                            ),
                            onChanged: (v) => vm.updateFeatureValue(index, v),
                          ),
                        ),
                        if (vm.model.features.length > 1)
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.grey, size: 22),
                            onPressed: () => vm.removeFeatureField(index),
                          )
                        else
                          const SizedBox(width: 48),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              GestureDetector(
                onTap: vm.model.features.length < 8 ? () => vm.addFeatureField() : null,
                child: Container(
                  height: 48,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.blue.shade200, style: BorderStyle.solid),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add, size: 18, color: vm.model.features.length < 8 ? const Color(0xFF1976D2) : Colors.grey),
                      const SizedBox(width: 6),
                      Text(
                        "Thêm đặc điểm",
                        style: TextStyle(
                          color: vm.model.features.length < 8 ? const Color(0xFF1976D2) : Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 14
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  "Bạn có thể thêm tối đa 8 đặc điểm nổi bật.",
                  style: TextStyle(color: Colors.grey[400], fontSize: 11, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  IconData _getFeatureIcon(int index) {
    const icons = [Icons.star_border, Icons.flash_on_outlined, Icons.battery_charging_full_outlined, Icons.card_giftcard_outlined, Icons.accessibility_new_outlined];
    return icons[index % icons.length];
  }

  String _getHintExample(int step) {
    const hints = [
      "Ví dụ: Thiết kế hiện đại, dễ sử dụng",
      "Ví dụ: Tình trạng như mới 95%",
      "Ví dụ: Pin lâu, dùng liên tục 8h",
      "Ví dụ: Phụ kiện đầy đủ",
      "Ví dụ: Gọn nhẹ, dễ mang theo"
    ];
    if (step >= 0 && step < hints.length) return hints[step];
    return "Ví dụ: Hoạt động bền bỉ, êm ái";
  }

  Widget _buildPremiumCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: child,
    );
  }
}