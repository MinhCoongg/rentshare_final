import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:rentshare_app/constant/constant_url.dart';
import 'package:rentshare_app/models/unit_model.dart';

class UnitService {
  static Future<List<UnitModel>> fetchUnitsByAttribute(int attributeId) async {
    final response = await http.get(Uri.parse('${ConstantURL.baseUrl}/attributes/$attributeId/units'));
    
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['data'];
      return data.map((item) => UnitModel.fromJson(item)).toList();
    } else {
      throw Exception("Không thể tải đơn vị: ${response.statusCode}");
    }
  }
}