class ShopHomeModel {
  final int id;
  final String name;
  final String avatar;
  final int totalProducts;
  final double shopRating;
  final int totalReviews;

  ShopHomeModel({
    required this.id,
    required this.name,
    required this.avatar,
    required this.totalProducts,
    required this.shopRating,
    required this.totalReviews,
  });

  factory ShopHomeModel.fromJson(Map<String, dynamic> json) {
    return ShopHomeModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Chủ shop uy tín',
      avatar: json['avatar'] ?? '',
      totalProducts: json['totalProducts'] is int ? json['totalProducts'] : (int.tryParse(json['totalProducts']?.toString() ?? '0') ?? 0),
      shopRating: double.tryParse(json['shopRating']?.toString() ?? '5.0') ?? 5.0,
      totalReviews: json['totalReviews'] is int ? json['totalReviews'] : (int.tryParse(json['totalReviews']?.toString() ?? '0') ?? 0),
    );
  }
}