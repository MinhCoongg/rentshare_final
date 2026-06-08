import 'package:rentshare_app/models/policy_model.dart';

class PostProductModel {
  int? categoryId;
  String title = "";
  String description = "";
  List<String> images = [];
  List<String> features = []; 
  Map<int, String> dynamicAttributes = {};
  double depositAmount = 0.0;
  int quantity = 1;
  String location = "";
  List<PolicyModel> policies = [];
  List<Map<String, dynamic>> tierPrices = [];

  double get pricePerDay => (tierPrices.isNotEmpty && tierPrices[0]['pricePerDay'] != null)
      ? (tierPrices[0]['pricePerDay'] as double)
      : 0.0;

  Map<String, dynamic> toJson() {
    String featuresString = features.isNotEmpty ? features.join(' | ') : "";
    return {
      "basicInfo": {
        "categoryId": categoryId,
        "title": title,
        "description": description,
        "images": images,
        "features": featuresString, 
      },
      "details": dynamicAttributes.entries
          .map((entry) => {
                "id": entry.key,
                "value": entry.value,
              })
          .toList(),
      "pricing": {
        "depositAmount": depositAmount,
        "quantity": quantity,
        "tierPrices": tierPrices.map((tier) => {
              "minDays": tier["minDays"],
              "pricePerDay": tier["pricePerDay"],
            }).toList(),
      },
      "shipping": {
        "location": location,
      },
      "policies": policies
          .map((policy) => policy.toJson())
          .toList(),
    };
  }
  
  void reset() {
    categoryId = null;
    title = "";
    description = "";
    images.clear();
    dynamicAttributes.clear();
    features.clear(); 
    tierPrices.clear(); 
    depositAmount = 0.0;
    quantity = 1;
    location = "";
    policies.clear();
  }
}