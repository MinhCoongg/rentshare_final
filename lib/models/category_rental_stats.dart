class CategoryRentalStats {
  final String categoryName;
  final int rentalCount;

  CategoryRentalStats({
    required this.categoryName,
    required this.rentalCount,
  });

  factory CategoryRentalStats.fromJson(Map<String, dynamic> json) {
    return CategoryRentalStats(
      categoryName: json['categoryName'] ?? '',
      rentalCount: json['rentalCount'] ?? 0,
    );
  }
}