import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:rentshare_app/constant/constant_url.dart';
import 'package:rentshare_app/utils/sharetoken_utils.dart';

class UserService {
  Future<Map<String, dynamic>> fetchUsers({String status = '', String search = ''}) async {
    final token = await SharedPrefsUtils.getToken();
    
    final url = Uri.parse('${ConstantURL.baseUrl}/users?status=$status&search=$search');
    
    final response = await http.get(
      url, 
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body); 
    } else {
      throw Exception('Không thể tải danh sách người dùng: ${response.statusCode}');
    }
  }

  Future<void> updateStatus(int userId, String status) async {
    final token = await SharedPrefsUtils.getToken();
    final response = await http.patch(
      Uri.parse('${ConstantURL.baseUrl}/users/status'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'userId': userId,
        'status': status,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Cập nhật trạng thái thất bại!');
    }
  }
}