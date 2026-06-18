class ShopInfo {
  final String receiverName;
  final String receiverPhone;
  final String address;

  ShopInfo({
    required this.receiverName,
    required this.receiverPhone,
    required this.address,
  });

  factory ShopInfo.fromJson(Map<String, dynamic> json) {
    return ShopInfo(
      receiverName: json['receiverName'] ?? '',
      receiverPhone: json['receiverPhone'] ?? '',
      address: json['address'] ?? '',
    );
  }
}