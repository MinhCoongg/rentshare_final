import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rentshare_app/constant/constant_url.dart';
import 'package:rentshare_app/models/rentalOrderDetail.dart';
import 'package:rentshare_app/models/rentalOrderItem.dart';
import 'package:rentshare_app/utils/sharetoken_utils.dart';


class RentalOrderService {
  Future<List<RentalOrderModel>> fetchMyOrders({String? status}) async {
    try {
      final String token = await SharedPrefsUtils.getToken();
      String url = '${ConstantURL.baseUrl}/rental/my-orders'; 
      
      if (status != null && status.isNotEmpty) {
        url += '?status=$status';
      }

      final response = await http.get(Uri.parse(url), headers: {"Authorization": "Bearer $token"});
      if (response.statusCode == 200) {
        final Map<String, dynamic> resData = jsonDecode(response.body);
        if (resData['success'] == true) {
          final List listData = resData['data'] ?? [];
          return listData.map((e) => RentalOrderModel.fromJson(e)).toList();
        }
      }
      return [];
    } catch (e) {
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


    Future<Map<String, dynamic>> cancelRentalOrder(int orderId) async {
      try {
        final String token = await SharedPrefsUtils.getToken(); 
        final response = await http.post(
          Uri.parse('${ConstantURL.baseUrl}/cancel-order'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: json.encode({
            'rentalRequestId': orderId, 
          }),
        );

        final Map<String, dynamic> decodedData = json.decode(response.body);

        if (response.statusCode == 200 && decodedData['success'] == true) {
          return {'success': true, 'message': decodedData['message']};
        } else {
          return {'success': false, 'message': decodedData['message'] ?? 'Hủy đơn thất bại'};
        }
      } catch (e) {
        debugPrint("Lỗi RentalOrderService (cancelRentalOrder): $e");
        return {'success': false, 'message': 'Lỗi kết nối hệ thống: ${e.toString()}'};
      }
    }

    Future<RentalOrderDetailModel?> fetchOrderDetailForOwner(int orderId) async {
    try {
      final String token = await SharedPrefsUtils.getToken();
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
      debugPrint("Lỗi Service fetchOrderDetailForOwner: $e");
      return null;
    }
  }


  Future<bool> approveRentalRequest(int orderId) async {
    try {
      final String token = await SharedPrefsUtils.getToken();
      final response = await http.post(
        Uri.parse('${ConstantURL.baseUrl}/rental/approve-request'), 
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'rentalRequestId': orderId}),
      );
      final Map<String, dynamic> data = json.decode(response.body);
      return response.statusCode == 200 && data['success'] == true;
    } catch (e) {
      return false;
    }
  }


  Future<bool> rejectRentalRequest(int orderId, String reason) async {
    try {
      final String token = await SharedPrefsUtils.getToken();
      final response = await http.post(
        Uri.parse('${ConstantURL.baseUrl}/rental/reject-request'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'rentalRequestId': orderId,
          'cancelReason': reason,
        }),
      );
      final Map<String, dynamic> data = json.decode(response.body);
      return response.statusCode == 200 && data['success'] == true;
    } catch (e) {
      return false;
    }
  }

  Future<List<RentalOrderModel>> fetchOwnerOrders({String? status}) async {
    try {
      final String token = await SharedPrefsUtils.getToken();
      String url = '${ConstantURL.baseUrl}/rental/my-orders?role=owner'; 
      
      if (status != null && status.isNotEmpty) {
        url += '&status=$status';
      }

      final response = await http.get(Uri.parse(url), headers: {"Authorization": "Bearer $token"});
      if (response.statusCode == 200) {
        final Map<String, dynamic> resData = jsonDecode(response.body);
        if (resData['success'] == true) {
          final List listData = resData['data'] ?? [];
          return listData.map((e) => RentalOrderModel.fromJson(e)).toList();
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}