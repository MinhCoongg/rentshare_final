import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rentshare_app/models/checkoutModel.dart';
import 'package:rentshare_app/utils/sharetoken_utils.dart';
import 'package:rentshare_app/constant/constant_url.dart';


class CheckoutService {
  
  
  Future<CheckoutDataModel?> getCheckoutInfo() async {
    try {
      String? token = await SharedPrefsUtils.getToken();

      
      final url = Uri.parse("${ConstantURL.baseUrl}/checkout-info"); 
      
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token", 
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        
        if (jsonResponse['success'] == true) {
      
          return CheckoutDataModel.fromJson(jsonResponse['data']); 
        }
      }
      
      debugPrint("API trả về mã lỗi: ${response.statusCode}");
      return null;
      
    } catch (e) {
      debugPrint("Lỗi kết nối từ Service checkout kịch trần: $e");
      return null;
    }
  }
}