import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:rentshare_app/constant/constant_url.dart';
import 'package:rentshare_app/models/address_model.dart';
import 'package:rentshare_app/utils/sharetoken_utils.dart';

class AddressService {
  static Future<List<AddressModel>> fetchUserAddresses() async {
    final url = Uri.parse("${ConstantURL.baseUrl}/user-addresses");
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
          final List<dynamic> addressListJson = responseData['data'];
          return addressListJson.map((json) => AddressModel.fromJson(json)).toList();
        } else {
          throw Exception(responseData['message'] ?? "Tải sổ địa chỉ thất bại!");
        }
      } else {
        throw Exception("Lỗi hệ thống: Mã trạng thái ${response.statusCode}");
      }
    } catch (error) {
      throw Exception("Không thể kết nối đến máy chủ: $error");
    }
  }

  
  static Future<AddressModel> createNewAddress(AddressModel newAddress) async {
    final url = Uri.parse("${ConstantURL.baseUrl}/add-address");
    final String jwtToken = await SharedPrefsUtils.getToken();
    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $jwtToken",
        },
        body: json.encode(newAddress.toJson()), 
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        
        if (responseData['success'] == true) {
          return AddressModel.fromJson(responseData['data']);
        } else {
          throw Exception(responseData['message'] ?? "Thêm địa chỉ mới thất bại!");
        }
      } else {
        throw Exception("Lỗi hệ thống: Mã trạng thái ${response.statusCode}");
      }
    } catch (error) {
      throw Exception("Không thể kết nối đến máy chủ: $error");
    }
  }
}