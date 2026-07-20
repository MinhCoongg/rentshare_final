class Voucher {
  final int id;
  final String code;
  final String title;
  final String discountType; // 'PERCENT' hoặc 'FIXED'
  final double discountValue;
  final double minOrderValue;
  final double maxDiscountAmount;
  final DateTime endDate;

  Voucher({
    required this.id,
    required this.code,
    required this.title,
    required this.discountType,
    required this.discountValue,
    required this.minOrderValue,
    required this.maxDiscountAmount,
    required this.endDate,
  });


  factory Voucher.fromJson(Map<String, dynamic> json) {
    return Voucher(
      id: json['id'],
      code: json['code'] ?? '',
      title: json['title'] ?? '',
      discountType: json['discountType'] ?? 'PERCENT',
      discountValue: double.parse(json['discountValue'].toString()),
      minOrderValue: double.parse(json['minOrderValue'].toString()),
      maxDiscountAmount: double.parse(json['maxDiscountAmount'].toString()),
      endDate: DateTime.parse(json['endDate']),
    );
  }
}