import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rentshare_app/constant/constant_url.dart';
import 'package:rentshare_app/models/rentalOrderDetail.dart';
import 'package:rentshare_app/models/rentalOrderItem.dart';
import 'package:rentshare_app/utils/sharetoken_utils.dart';


class RentalOrderService {
  Future<List<RentalOrderModel>> fetchMyOrders({
    String? status, 
  }) async {
    try {
      final String token =await SharedPrefsUtils.getToken();
      debugPrint(token);
      String url = '${ConstantURL.baseUrl}/rental/my-orders';
      if (status != null && status.isNotEmpty) {
        url += '?status=$status';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token", 
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> resData = jsonDecode(response.body);
        if (resData['success'] == true) {
          final List listData = resData['data'] ?? [];
          return listData.map((e) => RentalOrderModel.fromJson(e)).toList();
        }
      }
      return [];
    } catch (e) {
      debugPrint("Lỗi fetchMyOrders tại Service: $e");
      return [];
    }
  }


  Future<RentalOrderModel?> fetchOrderDetailById({
    required int orderId, 
  }) async {
    try {
      final String token =await SharedPrefsUtils.getToken();
      final response = await http.get(
        Uri.parse('${ConstantURL.baseUrl}/rental/detail/$orderId'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> resData = jsonDecode(response.body);
        if (resData['success'] == true && resData['data'] != null) {
          return RentalOrderModel.fromJson(resData['data']);
        }
      }
      return null;
    } catch (e) {
      debugPrint("Lỗi fetchOrderDetailById tại Service: $e");
      return null;
    }
  }

  Future<RentalOrderDetailModel?> fetchOrderDetail(int orderId) async {
    try {
      final String token =await SharedPrefsUtils.getToken();
      final response = await http.get(
        Uri.parse('${ConstantURL.baseUrl}/rental/detail/$orderId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedData = json.decode(response.body);
        if (decodedData['success'] == true && decodedData['data'] != null) {
          return RentalOrderDetailModel.fromJson(decodedData['data']);
        }
      }
      return null;
    } catch (e) {
      debugPrint("Lỗi RentalOrderService (fetchOrderDetail): $e");
      return null;
    }
  }
}