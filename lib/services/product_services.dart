import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:rentshare_app/constant/constant_url.dart';
import 'package:rentshare_app/models/productCriteria_model.dart';
import 'package:rentshare_app/models/product_model.dart';
import 'package:rentshare_app/models/producthome_model.dart';
import 'package:rentshare_app/utils/sharetoken_utils.dart'; 


class ProductDetailService {
  static Future<ProductModel?> fetchProductDetail(int productId) async {
    try {
      final url = Uri.parse('${ConstantURL.baseUrl}/products/$productId'); 
      final String token = await SharedPrefsUtils.getToken();
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token', 
          'Accept': 'application/json',
        },
      );

      debugPrint("[ProductDetailService] Mã Http Status trả về: ${response.statusCode}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonResult = jsonDecode(response.body);
        
        if (jsonResult['succeeded'] == true && jsonResult['data'] != null) {
          return ProductModel.fromJson(jsonResult['data']);
        }
      }
      return null;
    } catch (e) {
      debugPrint("[ProductDetailService] Khủng hoảng lỗi khi fetch chi tiết sản phẩm: $e");
      return null;
    }
  }

  Future<List<ProductHomeModel>> fetchFilteredProducts(Map<String, dynamic> filters) async {
    try {
      final url = Uri.parse('${ConstantURL.baseUrl}/products/filter');
      debugPrint('SQL $filters');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json', 
        },
        body: jsonEncode(filters), 
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        
        if (responseData['success'] == true) {
          final List<dynamic> data = responseData['data'];
          return data.map((json) => ProductHomeModel.fromJson(json)).toList();
        }
      }
      return [];
    } catch (e) {
      debugPrint("Lỗi gọi API filter (POST): $e");
      return [];
    }
  }

  Future<List<ProductHomeModel>> fetchMyProducts() async {
    try {
      final token = await SharedPrefsUtils.getToken();
      final response = await http.get(
        Uri.parse('${ConstantURL.baseUrl}/my-products'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> resData = jsonDecode(response.body);
        if (resData['success'] == true) {
          final List<dynamic> listData = resData['data'] ?? [];
          return listData.map((json) => ProductHomeModel.fromJson(json)).toList();
        }
      }else{
        debugPrint("LỖI STATUS CODE: ${response.statusCode}");
      }
      return [];
    } catch (e) {
      debugPrint("Lỗi fetchMyProducts: $e");
      return [];
    }
  }

  Future<List<ProductCriteria>> fetchCriteria() async {
    try {
      final response = await http.get(
        Uri.parse('${ConstantURL.baseUrl}/product-criteria'), 
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> resData = jsonDecode(response.body);
        if (resData['success'] == true) {
          final List<dynamic> listData = resData['data'] ?? [];
          return listData.map((json) => ProductCriteria.fromJson(json)).toList();
        }
      } else {
        debugPrint("LỖI STATUS CODE: ${response.statusCode}");
      }
      return [];
    } catch (e) {
      debugPrint("Lỗi fetchCriteria: $e");
      return [];
    }
  }


}