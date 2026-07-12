import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rentshare_app/constant/constant_url.dart';
import 'package:rentshare_app/models/productShop.dart';
import 'package:rentshare_app/models/producthome_model.dart';
 

class ShopService {
  //Này là người dùng bấm vào shop hoặc chọn sp thêm ở vào giỏ hàng
  static Future<ShopDetailModel> fetchShopDetail(int shopId) async {
    final response = await http.get(Uri.parse('${ConstantURL.baseUrl}/shop-products/$shopId'));
    
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return ShopDetailModel.fromJson(jsonResponse['data']);
    } else {
      throw Exception('Lỗi không lấy được dữ liệu shop');
    }
  }


  //Này là shop (ngyuowif cho thuê) quản lý sp 
  static Future<List<ProductHomeModel>> getMyProducts(String token) async {
    final response = await http.get(
      Uri.parse('${ConstantURL.baseUrl}/my-products-manager'),
      headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['data'];
      return data.map((json) => ProductHomeModel.fromJson(json)).toList();
    } else {
      throw Exception("Không thể lấy danh sách sản phẩm");
    }
  }


  static Future<bool> toggleStatus(String token, int productId, String status) async {
    final response = await http.patch(
      Uri.parse('${ConstantURL.baseUrl}/toggle-status'),
      headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
      body: json.encode({'productId': productId, 'status': status}),
    );

    // Ní in cái response.body ra đây để xem lỗi cụ thể là gì
    if (response.statusCode == 200) {
      return true;
    } else {
      debugPrint("LỖI SERVER TRẢ VỀ: ${response.body}"); // DÒNG NÀY RẤT QUAN TRỌNG
      return false;
    }
  }
}