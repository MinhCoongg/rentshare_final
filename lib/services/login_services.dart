import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:rentshare_app/constant/constant_url.dart';
import '../models/user_model.dart';

class LoginServices {

  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${ConstantURL.baseUrl}/login'),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['succeeded'] == true) {
        return {
          'succeeded': true,
          'message': responseData['message'],
          'token': responseData['token'],
          'user': UserModel.fromJson(responseData['user']),
        };
      } else {
        return {
          'succeeded': false,
          'message': responseData['message'] ?? 'Đăng nhập thất bại!',
        };
      }
    } catch (error) {
      return {
        'succeeded': false,
        'message': 'Lỗi kết nối hệ thống: $error',
      };
    }
  }

  static Future<bool> registerUser({
    required String name,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    final url = Uri.parse('${ConstantURL.baseUrl}/register');
    
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': name,
        'email': email,
        'phoneNumber': phoneNumber,
        'password': password,
        'roleId': 2, 
      }),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      final error = json.decode(response.body)['message'];
      throw Exception(error ?? "Đăng ký thất bại");
    }
  }
}