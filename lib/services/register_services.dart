import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:rentshare_app/constant/constant_url.dart';

class RegisterServices {
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ConstantURL.baseUrl}/register'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'name': name,
          'email': email,
          'phoneNumber': phone, // Khớp chuẩn key 'phoneNumber' ở Backend nhận
          'password': password,
        }),
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {
          'succeeded': true,
          'message': responseData['message'] ?? 'Đăng ký thành công!',
        };
      } else {
        return {
          'succeeded': false,
          'message': responseData['message'] ?? 'Đăng ký thất bại!',
        };
      }
    } catch (error) {
      return {'succeeded': false, 'message': 'Lỗi kết nối hệ thống: $error'};
    }
  }
}
