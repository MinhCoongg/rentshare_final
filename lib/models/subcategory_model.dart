class SubCategoryModel {
  final int id;
  final String categoryName;
  final int? parentId;

  SubCategoryModel({
    required this.id,
    required this.categoryName,
    this.parentId,
  });

  factory SubCategoryModel.fromJson(Map<String, dynamic> json) {
    return SubCategoryModel(
      id: json['id'],
      categoryName: json['categoryName'],
      parentId: json['parentId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoryName': categoryName,
      'parentId': parentId,
    };
  }
}