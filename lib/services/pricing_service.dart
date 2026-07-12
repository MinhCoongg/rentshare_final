import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:rentshare_app/constant/constant_url.dart'; 
import 'package:rentshare_app/models/tierPerDay_model.dart'; 
class TierService {
  static Future<List<TierPricingModel>> fetchProductTiers(int productId) async {

    final url = Uri.parse("${ConstantURL.baseUrl}/tier-pricing?productId=$productId"); 
    
    try {
     
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json", 
        },
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body); 
        
        if (responseData['success'] == true) {
          final List<dynamic> tierListJson = responseData['data']; 
          return tierListJson.map((json) => TierPricingModel.fromJson(json)).toList(); //
        } else {
          throw Exception(responseData['message'] ?? "Tải bảng bậc giá sản phẩm thất bại ní ơi!"); //
        }
      } else {
        throw Exception("Lỗi hệ thống: Mã trạng thái ${response.statusCode}"); //
      }
    } catch (error) {
      throw Exception("Không thể kết nối đến máy chủ bốc lửa: $error"); 
    }
  }
}