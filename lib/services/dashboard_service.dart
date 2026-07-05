import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:rentshare_app/constant/constant_url.dart';
import 'package:rentshare_app/models/category_rental_stats.dart';
import 'package:rentshare_app/models/dashboarData_model.dart';
import 'package:rentshare_app/utils/sharetoken_utils.dart';

class DashboardService {
  static Future<DashboardData> fetchDashboardData() async {
    final url = Uri.parse("${ConstantURL.baseUrl}/admin/dashboard");
    final String jwtToken = await SharedPrefsUtils.getToken();

    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $jwtToken",
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return DashboardData.fromJson(jsonResponse['data']);
    } else {
      throw Exception("Lỗi server: ${response.statusCode}");
    }
  }

  static Future<List<CategoryRentalStats>> fetchTopCategories() async {
    final url = Uri.parse("${ConstantURL.baseUrl}/dashboard/top-categories");
    final String jwtToken = await SharedPrefsUtils.getToken();

    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $jwtToken",
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return (jsonResponse['data'] as List)
          .map((e) => CategoryRentalStats.fromJson(e))
          .toList();
    } else {
      throw Exception("Lỗi server: ${response.statusCode}");
    }
  }
}