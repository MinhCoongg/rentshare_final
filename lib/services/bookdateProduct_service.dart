import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rentshare_app/constant/constant_url.dart';

class BookDateProduct {
  static Future<List<String>> fetchBookedDates(List<int> productIds) async {
    try {
      final response = await http.post(
        Uri.parse('${ConstantURL.baseUrl}/booked-dates'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"productIds": productIds}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        
        if (data['success'] == true && data['bookedDates'] != null) {
          return List<String>.from(data['bookedDates']);
        }
      }
      return [];
    } catch (e) {
      debugPrint("Lỗi API gọi ngày trùng lịch: $e");
      return [];
    }
  }
}