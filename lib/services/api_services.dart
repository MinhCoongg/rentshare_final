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
    final response = await http.get(Uri.parse('${ConstantURL.baseUrl}/categories'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(utf8.decode(response.bodyBytes));
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

      debugPrint("B4");

      request.headers.addAll({
        'Authorization': 'Bearer $token',
      });

      debugPrint("B5");

      request.fields['body'] = jsonEncode(product.toJson());

      debugPrint("B6");

      if (imageFiles.isNotEmpty) {
        for (var file in imageFiles) {
          debugPrint("Adding file: ${file.path}");

          request.files.add(
            await http.MultipartFile.fromPath(
              'images',
              file.path,
            ),
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
  
}