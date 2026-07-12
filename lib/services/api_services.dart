import 'dart:convert';
import 'dart:io';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'package:rentshare_app/constant/constant_url.dart';
import 'package:rentshare_app/models/attribute_model.dart';
import 'package:rentshare_app/models/category_model.dart';
import 'package:rentshare_app/models/post_product_model.dart';
import 'package:rentshare_app/utils/sharetoken_utils.dart';


class ApiService {
<<<<<<< HEAD
  static Future<Map<String, dynamic>> getProductById(int id) async {
    final res = await http.get(
      Uri.parse("${ConstantURL.baseUrl}/products/$id"),
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception("Failed to load product");
    }
  }
=======
  
>>>>>>> origin/fix

  static Future<List<AttributeModel>> getCategoryFields(int categoryId) async {
    try {
      final response = await http.get(
        Uri.parse('${ConstantURL.baseUrl}/category-fields/$categoryId'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        if (data['succeeded'] == true) {
          final List<dynamic> attributesJson = data['data'];
          return attributesJson
              .map((json) => AttributeModel.fromJson(json))
              .toList();
        }
      }
      throw Exception("Lỗi khi lấy thuộc tính danh mục");
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<CategoryModel>> getAllCategories() async {
    final response = await http.get(
      Uri.parse('${ConstantURL.baseUrl}/categories'),
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(
        utf8.decode(response.bodyBytes),
      );
      final List<dynamic> data = responseData['data'];
      return data.map((json) => CategoryModel.fromJson(json)).toList();
    } else {
      throw Exception("Lỗi lấy danh mục từ Server");
    }
  }

  static Future<bool> submitProduct({
    required PostProductModel product,
    required List<File> imageFiles,
  }) async {
    try {
      debugPrint("B1");


      final token = await SharedPrefsUtils.getToken();
      debugPrint("B3 Token = $token");


      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ConstantURL.baseUrl}/add-product'),
      );

<<<<<<< HEAD
      request.headers.addAll({'Authorization': 'Bearer $token'});
=======
      debugPrint("B4");

      request.headers.addAll({
        'Authorization': 'Bearer $token',
      });

      debugPrint("B5");

>>>>>>> origin/fix
      request.fields['body'] = jsonEncode(product.toJson());

      debugPrint("B6");

      if (imageFiles.isNotEmpty) {
        for (var file in imageFiles) {
          debugPrint("Adding file: ${file.path}");

          request.files.add(
<<<<<<< HEAD
            await http.MultipartFile.fromPath('images', file.path),
=======
            await http.MultipartFile.fromPath(
              'images',
              file.path,
            ),
>>>>>>> origin/fix
          );
        }
      }

      debugPrint("B7 Before Send");

      final streamedResponse = await request.send();

      debugPrint("B8 After Send");

      final response = await http.Response.fromStream(streamedResponse);

      debugPrint("B9 After Response");

      debugPrint("StatusCode = ${response.statusCode}");
      debugPrint("Response = ${response.body}");

      return response.statusCode == 200 ||
          response.statusCode == 201;
    } catch (e, stack) {
      debugPrint("ERROR = $e");
      debugPrint("$stack");
      return false;
    }
  }

  // ============================================
  // 🔥 ĐĂNG KÝ - THÊM MỚI
  // ============================================
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String phoneNumber,
    required String password,
    String? avatar,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ConstantURL.baseUrl}/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'phoneNumber': phoneNumber,
          'password': password,
          'avatar': avatar ?? '/uploads/rentshare.jpg',
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': data['message'] ?? 'Đăng ký thành công',
          'data': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Đăng ký thất bại',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }

  // ============================================
  // 🔥 SOCIAL LOGIN (GOOGLE/FACEBOOK) - THÊM MỚI
  // ============================================
  static Future<Map<String, dynamic>> socialLogin({
    required String email,
    required String name,
    required String provider,
    required String providerId,
    String? avatar,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ConstantURL.baseUrl}/social-login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'name': name,
          'provider': provider,
          'providerId': providerId,
          'avatar': avatar,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Đăng nhập thành công',
          'data': {'user': data['user'], 'token': data['token']},
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Đăng nhập thất bại',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }

  // ============================================
  // 🔥 LẤY PROFILE (THÊM MỚI)
  // ============================================
  static Future<Map<String, dynamic>?> getProfile() async {
    try {
      final pref = await SharedPreferences.getInstance();
      final token = pref.getString('token');

      if (token == null) return null;

      final response = await http.get(
        Uri.parse('${ConstantURL.baseUrl}/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('Lỗi lấy profile: $e');
      return null;
    }
  }
}
