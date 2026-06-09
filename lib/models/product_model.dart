import 'package:rentshare_app/models/policy_model.dart';
import 'package:rentshare_app/models/reviews_model.dart';

class ProductModel {
  final int id;
  final String title, description, pricePerDay, depositAmount;
  final String ownerName, ownerAvatar, location, categoryName;
  final List<String> images;
  final Map<String, dynamic> specifications;  
  final List<ReviewModel> reviews; 
  final List<PolicyModel> policies;
  final List<Map<String, dynamic>> tierPricings; 

  ProductModel({
    required this.id, required this.title, required this.description,
    required this.pricePerDay, required this.depositAmount,
    required this.ownerName, required this.ownerAvatar,
    required this.location, required this.categoryName,
    required this.images, required this.specifications, 
    required this.reviews, required this.policies,
    required this.tierPricings,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final tierPricingsList = (json['tierPricings'] as List? ?? [])
        .map((e) => Map<String, dynamic>.from(e))
        .toList();

    String autoPrice = '0';
    if (tierPricingsList.isNotEmpty) {
      autoPrice = tierPricingsList[0]['pricePerDay']?.toString() ?? '0';
    }

    return ProductModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      pricePerDay: autoPrice, 
      depositAmount: json['depositAmount']?.toString() ?? '0.00',
      ownerName: json['ownerName'] ?? 'Unknown',
      ownerAvatar: json['ownerAvatar'] ?? '',
      location: json['location'] ?? '',
      categoryName: json['categoryName'] ?? '',
      images: (json['images'] as List? ?? [])
          .map((img) => img.toString())
          .toList(),
          
      specifications: Map<String, dynamic>.from(json['specifications'] ?? {}),
      
      tierPricings: tierPricingsList,

      reviews: (json['reviews'] as List? ?? [])
          .map((r) => ReviewModel.fromJson(r))
          .toList(),

      policies: (json['policies'] as List? ?? [])
          .map((p) => PolicyModel.fromJson(p))
          .toList(),
    );
  }
}