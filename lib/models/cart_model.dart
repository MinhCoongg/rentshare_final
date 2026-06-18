class RentalCartItem {
  final int productId;
  final int ownerId;
  final String ownerName; 
  final String ownerAvatar;
  final String ownerAddress; 
  final String title;
  final String image;
  final double pricePerDay;
  final int maxStock; 
  int quantity;
  double depositAmount;

  RentalCartItem({
    required this.productId,
    required this.ownerId,
    required this.ownerName, 
    required this.ownerAvatar,
    required this.ownerAddress, 
    required this.title,
    required this.image,
    required this.pricePerDay,
    required this.maxStock, 
    required this.quantity,
    required this.depositAmount,
  });

  Map<String, dynamic> toJson() {
    return {
      "productId": productId,
      "ownerId": ownerId,
      "ownerName": ownerName, 
      "ownerAvatar": ownerAvatar,
      "ownerAddress": ownerAddress, 
      "title": title,
      "image": image,
      "pricePerDay": pricePerDay,
      "maxStock": maxStock, 
      "quantity": quantity,
      "depositAmount": depositAmount,
    };
  }

  factory RentalCartItem.fromJson(Map<String, dynamic> json) {
    return RentalCartItem(
      productId: json["productId"] ?? 0,
      ownerId: json["ownerId"] ?? 0,
      ownerName: json["ownerName"] ?? 'Chủ shop Rentshare',
      ownerAvatar: json['ownerAvatar'] ?? 'rentshare.png',
      ownerAddress: json['ownerAddress'] ?? 'Địa chỉ shop đang cập nhật...',
      title: json["title"] ?? '',
      image: json["image"] ?? '',
      pricePerDay: (json["pricePerDay"] as num?)?.toDouble() ?? 0.0,
      maxStock: json["maxStock"] ?? 1,
      quantity: json["quantity"] ?? 1,
      depositAmount: (json["depositAmount"] as num?)?.toDouble() ?? 0.0,
    );
  }
}