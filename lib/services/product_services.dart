import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:rentshare_app/constant/constant_url.dart';
import 'package:rentshare_app/models/product_model.dart';
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
}