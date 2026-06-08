import 'package:intl/intl.dart';

class FormatUtils {
  static String formatMoney(double amount) {
    final formatter = NumberFormat("#,###", "vi_VN");
    return formatter.format(amount);
  }

  static double parseMoney(String text) {
    return double.tryParse(text.replaceAll('.', '').replaceAll(',', '')) ?? 0.0;
  }
}