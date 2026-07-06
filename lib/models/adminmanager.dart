class RentalOrder {
  final int id;
  final String orderCode;
  final DateTime startDate;
  final DateTime endDate;
  final String status;
  final String renterName;
  final String renterPhone;
  final String ownerName;
  final String ownerPhone;
  final double netIncome;
  final double depositFee;
  final String productName;
  final String productImage;

  RentalOrder({
    required this.id,
    required this.orderCode,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.renterName,
    required this.renterPhone,
    required this.ownerName,
    required this.ownerPhone,
    required this.netIncome,
    required this.depositFee,
    required this.productName,
    required this.productImage,
  });

  factory RentalOrder.fromJson(Map<String, dynamic> json) {
    return RentalOrder(
      id: json['id'] ?? 0,
      orderCode: json['orderCode'] ?? '',
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      status: json['status'] ?? '',
      renterName: json['renterName'] ?? '',
      renterPhone: json['renterPhone'] ?? '',
      ownerName: json['ownerName'] ?? '',
      ownerPhone: json['ownerPhone'] ?? '',
      // Dùng double.parse vì API trả về dạng String "85000.00"
      netIncome: double.tryParse(json['netIncome'].toString()) ?? 0.0,
      depositFee: double.tryParse(json['depositFee'].toString()) ?? 0.0,
      productName: json['productName'] ?? 'Không rõ sản phẩm',
      productImage: json['productImage'] ?? '',
    );
  }
}