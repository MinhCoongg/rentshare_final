import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:rentshare_app/constant/constant_url.dart';
import 'package:rentshare_app/models/user_model.dart';
import 'package:rentshare_app/utils/sharetoken_utils.dart';

class ProfileService {
  static Future<String?> uploadAvatr(File imageFile)async{

    final uri = '${ConstantURL.baseUrl}/upload-image-avatar';
    final url = Uri.parse(uri);
    try{
     final String token = await SharedPrefsUtils.getToken();
 
      var request = http.MultipartRequest('POST', url);
      request.headers['Authorization'] = 'Bearer $token';

      request.files.add(await http.MultipartFile.fromPath(
        'avatar', 
        imageFile.path,
      ));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['user']['avatar']; 
        }
      }
      throw Exception("Lỗi server: ${response.statusCode}");
    }catch (e) {
      throw Exception("Không thể upload ảnh: $e");
    }
  }

    static Future<UserModel> updateProfile({
    required UserModel user,
  }) async {
    final token = await SharedPrefsUtils.getToken();

    final response = await http.put(
      Uri.parse("${ConstantURL.baseUrl}/update-profile"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(user.toJson()),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      return UserModel.fromJson(data["user"]);
    } else {
      throw Exception("Cập nhật thất bại");
    }
  }

  static Future<bool> changePassword(String oldPass, String newPass)async{
    final uri = '${ConstantURL.baseUrl}/changePassword';
    final url = Uri.parse(uri);
    try{
      final String token =await SharedPrefsUtils.getToken();
      final response = await http.post(
        url,
        headers: {
          'Content-Type' : 'application/json',
          'Authorization' : 'Bearer $token'
        },
        body: jsonEncode({
          'oldPassword': oldPass,
          'newPassword': newPass,
        })
      );
      return response.statusCode == 200;
    }catch (e) {
      throw Exception("Không thể kết nối API: $e");
    }
  }
}