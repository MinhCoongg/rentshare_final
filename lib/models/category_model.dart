import 'package:rentshare_app/models/subcategory_model.dart';

class CategoryModel {
  final int id;
  final String categoryName;
  final int? parentId;
  final List<SubCategoryModel> subCategories;

  CategoryModel({
    required this.id,
    required this.categoryName,
    this.parentId,
    this.subCategories = const [],
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      categoryName: json['categoryName'],
      parentId: json['parentId'],
      subCategories: (json['subCategories'] as List?)
              ?.map((e) => SubCategoryModel.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoryName': categoryName,
      'parentId': parentId,
      'subCategories': subCategories.map((e) => e.toJson()).toList(),
    };
  }
}