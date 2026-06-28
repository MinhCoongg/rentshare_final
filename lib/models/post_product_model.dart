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
  int? addressId;
  String location = "";
  List<PolicyModel> policies = [];
  List<Map<String, dynamic>> tierPrices = [];

  double get pricePerDay => (tierPrices.isNotEmpty && tierPrices[0]['pricePerDay'] != null)
      ? (tierPrices[0]['pricePerDay'] as double)
      : 0.0;

  Map<String, dynamic> toJson() {
    return {
      "basicInfo": {
        "categoryId": categoryId,
        "title": title,
        "description": description,
        "images": images,
        "features": features, 
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
        
        "tierPricings": this.tierPrices.map((tier) => {
              "minDays": tier["minDays"],
              "pricePerDay": tier["pricePerDay"],
            }).toList(),
      },
      "shipping": {
        "addressId": addressId,
        "location": location,
      },
      
     
      "policies": policies
        .map((policy) => {
          "type": policy.type,
          "fineValue": policy.fineValue,
          "unit": policy.unit,
          "content": policy.content,
          "lightDamage": policy.lightDamage,
          "mediumDamage": policy.mediumDamage,
          "heavyDamage": policy.heavyDamage,
        })
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
    addressId = 0;
    quantity = 1;
    location = "";
    policies.clear();
  }
}