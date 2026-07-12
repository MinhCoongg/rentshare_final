import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:rentshare_app/constant/constant_url.dart';
import 'package:rentshare_app/utils/sharetoken_utils.dart';


class WalletService {
  static Future<Map<String, dynamic>> deposit(double amount) async {
    final url = Uri.parse("${ConstantURL.baseUrl}/deposit");
    final String jwtToken = await SharedPrefsUtils.getToken();

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $jwtToken",
        },
        body: jsonEncode({"amount": amount}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Lỗi nạp tiền: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Lỗi kết nối server: $e");
    }
  }

  static Future<Map<String, dynamic>> getWallet() async {
    final url = Uri.parse("${ConstantURL.baseUrl}/wallet");
    final String jwtToken = await SharedPrefsUtils.getToken();

    try {
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $jwtToken",
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Không thể lấy dữ liệu ví");
      }
    } catch (e) {
      throw Exception("Lỗi kết nối: $e");
    }
  }
}