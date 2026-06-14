class RentalCartItem {
  final int productId;
  final int ownerId;
  final String ownerName; 
  final String ownerAvatar;
  final String title;
  final String image;
  final double pricePerDay;
  final int maxStock; // 🎯 1. BƠM TRƯỜNG SỐ LƯỢNG KHO THẬT TRONG DB VÀO ĐÂY NÍ!
  int quantity;
  double depositAmount;

  RentalCartItem({
    required this.productId,
    required this.ownerId,
    required this.ownerName, 
    required this.ownerAvatar,
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
      "ownerAvatar" : ownerAvatar,
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
      title: json["title"] ?? '',
      image: json["image"] ?? '',
      pricePerDay: (json["pricePerDay"] as num?)?.toDouble() ?? 0.0,
      maxStock: json["maxStock"] ?? 1,
      quantity: json["quantity"] ?? 1,
      depositAmount: (json["depositAmount"] as num?)?.toDouble() ?? 0.0,
    );
  }
}