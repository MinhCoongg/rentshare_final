class ProductHomeModel {
  final int id;
  final int ownerId;
  final int categoryId;
  final int addressId;
  final String title;
  final String depositAmount;
  final double minPrice;
  final int quantity;
  final String status;
  final String createdAt;
  final String location; 
  final String images; 
  final double rating;     
  final int reviewCount;   

  ProductHomeModel({
    required this.id,
    required this.ownerId,
    required this.categoryId,
    required this.addressId,
    required this.title,
    required this.depositAmount,
    required this.minPrice,
    required this.quantity,
    required this.status,
    required this.createdAt,
    required this.location, 
    required this.images,
    required this.rating,
    required this.reviewCount,
  });

  factory ProductHomeModel.fromJson(Map<String, dynamic> json) {
    double parsedRating = 5.0;
    if (json['rating'] != null) {
      parsedRating = double.tryParse(json['rating'].toString()) ?? 5.0;
    }

    int parsedReviewCount = 0;
    if (json['reviewCount'] != null) {
      parsedReviewCount = int.tryParse(json['reviewCount'].toString()) ?? 0;
    }

    return ProductHomeModel(
      id: json['id'] ?? 0,
      ownerId: json['ownerId'] ?? 0,
      categoryId: json['categoryId'] ?? 0,
      addressId: json['addressId'] ?? 0,
      title: json['title'] ?? '',
      depositAmount: json['depositAmount']?.toString() ?? '0', 
      minPrice: double.tryParse(json['minPrice'].toString(),) ??0.0,
      quantity: json['quantity'] ?? 0,
      status: json['status'] ?? 'Available',
      createdAt: json['createdAt'] ?? '',
      location: json['location'] ?? 'TP. Hồ Chí Minh',
      images: json['thumbnail'] ?? '', 
      rating: parsedRating,      
      reviewCount: parsedReviewCount, 
    );
  }
}