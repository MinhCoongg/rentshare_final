import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:rentshare_app/constant/constant_url.dart';
import 'package:rentshare_app/models/adminProduct.dart';
import 'package:rentshare_app/models/adminmanager.dart';
import 'package:rentshare_app/utils/sharetoken_utils.dart';

class ProductAdminService {
  Future<List<Adminproduct>> fetchProducts(String status, String search) async {
    final token = await SharedPrefsUtils.getToken();
    final url = Uri.parse('${ConstantURL.baseUrl}/products-admin').replace(
      queryParameters: {
        if (status.isNotEmpty && status != 'All') 'status': status,
        if (search.isNotEmpty) 'search': search,
      },
    );
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', 
      },
    );
    if (response.statusCode == 200) {
      final List data = json.decode(response.body)['data'];
      return data.map((e) => Adminproduct.fromJson(e)).toList();
    } else if (response.statusCode == 401) {
      throw Exception("Token hết hạn hoặc không hợp lệ!");
    } else if (response.statusCode == 403) {
      throw Exception("Bạn không có quyền Admin!");
    }
    
    throw Exception("Không thể tải danh sách sản phẩm: ${response.statusCode}");
  }

  Future<bool> updateStatus(int productId, String status) async {
     final token = await SharedPrefsUtils.getToken();
    final response = await http.post(
      Uri.parse('${ConstantURL.baseUrl}/products/approve-admin'),
      body: json.encode({'productId': productId, 'status': status}),
       headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', 
      },
    );
    return response.statusCode == 200;
  }

  Future<Map<String, dynamic>> fetchOrdersData(String status, String search, int page) async {
    final token = await SharedPrefsUtils.getToken();
    final url = Uri.parse('${ConstantURL.baseUrl}/admin/orders').replace(queryParameters: {
      'status': status == 'All' ? '' : status,
      'search': search,
      'page': page.toString(),
    });

    final response = await http.get(url, headers: {'Authorization': 'Bearer $token'});

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final List<dynamic> ordersJson = body['data'];
      
      return {
        'data': ordersJson.map((json) => RentalOrder.fromJson(json)).toList(),
        'stats': Map<String, int>.from(body['stats']),
      };
    } else {
      throw Exception("Lỗi tải đơn hàng");
    }
  }

  
}