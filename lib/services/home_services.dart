import 'dart:convert';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'package:rentshare_app/constant/constant_url.dart';
import 'package:rentshare_app/models/category_model.dart';
import 'package:rentshare_app/models/producthome_model.dart';
import 'package:rentshare_app/models/shop_model.dart'; 

class HomeService {

  Future<List<CategoryModel>> getCategoryTree() async {
    try {
      final response = await http.get(Uri.parse('${ConstantURL.baseUrl}/categories'));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> listData = data['data'] ?? []; 
        return listData.map((e) => CategoryModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Lỗi HomeService - getCategoryTree: $e');
      return [];
    }
  }

 
  Future<Map<String, dynamic>> getHomePageProducts() async {
    try {
      final response = await http.get(Uri.parse('${ConstantURL.baseUrl}/products'));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> body = json.decode(response.body);
        final Map<String, dynamic> homeData = body['data'] ?? {}; 


        final List<dynamic> featuredJson = homeData['featuredProducts'] ?? [];
        List<ProductHomeModel> featured = featuredJson.map((e) => ProductHomeModel.fromJson(e)).toList();


        final List<dynamic> newestJson = homeData['newestProducts'] ?? [];
        List<ProductHomeModel> newest = newestJson.map((e) => ProductHomeModel.fromJson(e)).toList();


        final List<dynamic> suggestedJson = homeData['suggestedProducts'] ?? [];
        List<ProductHomeModel> suggested = suggestedJson.map((e) => ProductHomeModel.fromJson(e)).toList();

       
        final List<dynamic> shopJson = homeData['trustedShops'] ?? [];
        List<ShopHomeModel> shops = shopJson.map((e) => ShopHomeModel.fromJson(e)).toList(); 

        return {
          'featured': featured,
          'newest': newest,
          'suggested': suggested,
          'shops': shops, 
        };
      }
      return {'featured': [], 'newest': [], 'suggested': [], 'shops': []};
    } catch (e) {
      debugPrint('Lỗi HomeService - getHomePageProducts: $e');
      return {'featured': [], 'newest': [], 'suggested': [], 'shops': []};
    }
  }
}