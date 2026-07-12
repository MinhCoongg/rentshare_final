import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rentshare_app/constant/constant_url.dart';
import 'package:rentshare_app/models/damageReport.dart';
import 'package:rentshare_app/models/policy_model.dart';
import 'package:rentshare_app/models/rentalOrderDetail.dart';
import 'package:rentshare_app/utils/sharetoken_utils.dart';


class RentalOrderService {
  Future<List<RentalOrderDetailModel>> fetchMyOrders({String? status}) async {
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
          return listData.map((e) => RentalOrderDetailModel.fromJson(e)).toList();
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }


  Future<RentalOrderDetailModel?> fetchOrderDetailById({
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
          return RentalOrderDetailModel.fromJson(resData['data']);
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
      else{
        debugPrint('${response.body}');
        debugPrint('Lỗi fetch order');
      }
      return null;
    } catch (e) {
      debugPrint("Lỗi Service fetchOrderDetailForOwner: $e");
      return null;
    }
  }


  Future<bool> approveRentalRequest(int orderId, List<Map<String, dynamic>> rejectedItems) async {
    try {
      final String token = await SharedPrefsUtils.getToken();
      final response = await http.post(
        Uri.parse('${ConstantURL.baseUrl}/rental/approve-request'), 
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: json.encode({
          'rentalRequestId': orderId,
          'rejectedItems': rejectedItems, 
        }),
      );
      return response.statusCode == 200;
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

  Future<List<RentalOrderDetailModel>> fetchOwnerOrders({String? status}) async {
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
          return listData.map((e) => RentalOrderDetailModel.fromJson(e)).toList();
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<bool> renterRequestReturn(int orderId, File imageFile, String tracking, String note) async {
    try {
      final token = await SharedPrefsUtils.getToken();
      
      var request = http.MultipartRequest('POST', Uri.parse('${ConstantURL.baseUrl}/rental/renter-return'));
      
      request.headers.addAll({'Authorization': 'Bearer $token'});
      
      // Đẩy các thông tin text vào request.fields
      request.fields['rentalRequestId'] = orderId.toString();
      request.fields['trackingNumber'] = tracking;
      request.fields['note'] = note;
      
      // Đẩy file ảnh vào request.files
      request.files.add(await http.MultipartFile.fromPath('returnProof', imageFile.path));
      
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Lỗi upload: $e");
      return false;
    }
  }

    Future<Map<String, dynamic>> reportDamage(
      int rentalRequestId, String note, double compensation, File? imageFile) async {
    
    final url = Uri.parse('${ConstantURL.baseUrl}/rental/report-damage');
    debugPrint("--- BẮT ĐẦU GỬI BÁO CÁO HƯ HỎNG ---");
    debugPrint("URL: $url");
    debugPrint("Data: ID=$rentalRequestId, Note=$note, Fee=$compensation");
    final String token = await SharedPrefsUtils.getToken();
    var request = http.MultipartRequest('POST', url);
    request.headers['Authorization'] = 'Bearer $token';
    request.fields['rentalRequestId'] = rentalRequestId.toString();
    request.fields['note'] = note;
    request.fields['compensation'] = compensation.toString();
    
    if (imageFile != null) {
      debugPrint("Có file ảnh: ${imageFile.path}");
      request.files.add(await http.MultipartFile.fromPath('proof', imageFile.path));
    } else {
      debugPrint("Không có file ảnh đính kèm!");
    }

    try {
      var response = await request.send();
      debugPrint("Server phản hồi (Status Code): ${response.statusCode}");
      
      var responseData = await response.stream.bytesToString();
      debugPrint("Server phản hồi (Body): $responseData");
      
      return json.decode(responseData);
    } catch (e) {
      debugPrint("LỖI KHI GỬI HTTP REQUEST: $e");
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<List<PolicyModel>> fetchPolicies(int productId) async {
    try {
      final response = await http.get(Uri.parse('${ConstantURL.baseUrl}/rental/policy/$productId'));
      final Map<String, dynamic> responseData = json.decode(response.body);
      
      if (responseData['success'] == true) {
        final List<dynamic> data = responseData['data'];
        return data.map((json) => PolicyModel.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint("Lỗi khi fetch policies: $e");
    }
    return []; 
  }

  Future<DamageReport> getDamageReport(int rentalRequestId) async {
    try {
      final String token = await SharedPrefsUtils.getToken();
      final String url = '${ConstantURL.baseUrl}/rental/report-damage/$rentalRequestId';
      
      final response = await http.get(
        Uri.parse(url), 
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json"
        }
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> resData = jsonDecode(response.body);
        if (resData['success'] == true) {
          return DamageReport.fromJson(resData['data']);
        } else {
          throw Exception(resData['message'] ?? "Lỗi không xác định");
        }
      } else {
        throw Exception("Lỗi server: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Lỗi kết nối: $e");
    }
  }

  Future<Map<String, dynamic>> acceptDamageReport(int orderId) async {
    try {
      final String token = await SharedPrefsUtils.getToken();
      final response = await http.post(
        Uri.parse('${ConstantURL.baseUrl}/rental/accept-report/$orderId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      final Map<String, dynamic> data = json.decode(response.body);
      return {'success': response.statusCode == 200 && data['success'] == true, 'message': data['message']};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}