class ProductCriteria {
  final String criteriaName;
  final String description;

  ProductCriteria({
    required this.criteriaName,
    required this.description,
  });

  factory ProductCriteria.fromJson(Map<String, dynamic> json) {
    return ProductCriteria(
      criteriaName: json['criteria_name'] ?? '',
      description: json['description'] ?? '',
    );
  }
}