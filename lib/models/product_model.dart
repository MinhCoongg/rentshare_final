
import 'package:rentshare_app/models/policy_model.dart';
import 'package:rentshare_app/models/reviews_model.dart';

class ProductModel {
  final int id;
  final String title, description, pricePerDay, depositAmount;
  final String ownerName, ownerAvatar, location, categoryName;
  final List<String> images, features;
  final Map<String, String> specifications;
  final List<ReviewModel> reviews; 
  final List<PolicyModel> policies;

  ProductModel({
    required this.id, required this.title, required this.description,
    required this.pricePerDay, required this.depositAmount,
    required this.ownerName, required this.ownerAvatar,
    required this.location, required this.categoryName,
    required this.images, required this.features, 
    required this.specifications, required this.reviews,
    required this.policies,
  });


  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      pricePerDay: json['pricePerDay'],
      depositAmount: json['depositAmount'] ?? '0',
      ownerName: json['ownerName'] ?? 'Unknown',
      ownerAvatar: json['ownerAvatar'] ?? '',
      location: json['location'] ?? '',
      categoryName: json['categoryName'] ?? '',
      images: List<String>.from(json['images'] ?? []),
      features: List<String>.from(json['features'] ?? []),
      specifications: Map<String, String>.from(json['specifications'] ?? {}),
      reviews: (json['reviews'] as List? ?? [])
          .map((r) => ReviewModel.fromJson(r))
          .toList(),

      policies: (json['policies'] as List? ?? [])
          .map((p) => PolicyModel.fromJson(p))
          .toList(),
    );
  }
}