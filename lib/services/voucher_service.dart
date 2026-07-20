import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:rentshare_app/constant/constant_url.dart';
import 'package:rentshare_app/models/voucher_model.dart';
import 'package:rentshare_app/utils/sharetoken_utils.dart';

class VoucherService{
  Future<List<Voucher>> fetchAvailableVouchers() async {
    final String token = await SharedPrefsUtils.getToken();
    final response = await http.get(
      Uri.parse('${ConstantURL.baseUrl}/available-voucher'),
      headers: {"Authorization": "Bearer $token"}, 
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['data'];
      return data.map((json) => Voucher.fromJson(json)).toList();
    } else {
      throw Exception('Không tải được voucher');
    }
  }
}