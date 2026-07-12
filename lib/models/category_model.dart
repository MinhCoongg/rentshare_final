import 'package:rentshare_app/models/subcategory_model.dart';

class CategoryModel {
  final int id;
  final String categoryName;
  final int? parentId;
  final String? categoryImage; 
  final List<SubCategoryModel> subCategories;

  CategoryModel({
    required this.id,
    required this.categoryName,
    this.parentId,
    this.categoryImage,
    this.subCategories = const [],
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] ?? 0,
      categoryName: json['categoryName'] ?? '',
      parentId: json['parentId'],
      categoryImage: json['categoryImage'], 
      subCategories: (json['subCategories'] as List?)
              ?.map((e) => SubCategoryModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}