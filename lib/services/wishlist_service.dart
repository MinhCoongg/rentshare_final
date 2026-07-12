import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:rentshare_app/constant/constant_url.dart';
import 'package:rentshare_app/models/producthome_model.dart';
import 'package:rentshare_app/utils/sharetoken_utils.dart';


class WishlistService {
  static Future<List<ProductHomeModel>> fetchWishlist() async {
    final url = Uri.parse("${ConstantURL.baseUrl}/get-wishlist");
    final String jwtToken = await SharedPrefsUtils.getToken();
    
    try {
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $jwtToken",
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        
        if (responseData['success'] == true) {
          final List<dynamic> listJson = responseData['data'];
          return listJson.map((json) => ProductHomeModel.fromJson(json)).toList();
        } else {
          throw Exception(responseData['message'] ?? "Tải danh sách yêu thích thất bại!");
        }
      } else {
        throw Exception("Lỗi hệ thống: ${response.statusCode}");
      }
    } catch (error) {
      throw Exception("Không thể kết nối đến máy chủ: $error");
    }
  }

  static Future<String> toggleWishlist(int productId) async {
    final url = Uri.parse("${ConstantURL.baseUrl}/toggle");
    final String jwtToken = await SharedPrefsUtils.getToken();

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $jwtToken",
        },
        body: json.encode({"productId": productId}),
      );

      final Map<String, dynamic> responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        return responseData['message']; 
      } else {
        throw Exception(responseData['message'] ?? "Thao tác thất bại!");
      }
    } catch (error) {
      throw Exception("Lỗi kết nối: $error");
    }
  }
}