class RentalOrderDetailModel {
  final int id;
  final String orderCode;
  final String orderDate;
  final String startDateFormatted;
  final String endDateFormatted;
  final int rentalDays;
  final String status;
  final String shippingMethod;
  final String receiverName;
  final String receiverPhone;
  final String fullAddress;
  final String? notes; 
  final String rentalFee;
  final String depositFee;
  final String shippingFee;
  final String totalAmount;
  final String? cancelReason;
  final String ownerName;
  final String ownerAvatar;
  final List<OrderDetailItem> items;

  RentalOrderDetailModel({
    required this.id,
    required this.orderCode,
    required this.orderDate,
    required this.startDateFormatted,
    required this.endDateFormatted,
    required this.rentalDays,
    required this.status,
    required this.shippingMethod,
    required this.receiverName,
    required this.receiverPhone,
    required this.notes,
    required this.fullAddress,
    required this.rentalFee,
    required this.depositFee,
    required this.shippingFee,
    required this.totalAmount,
    this.cancelReason,
    required this.ownerName,
    required this.ownerAvatar,
    required this.items,
  });

  factory RentalOrderDetailModel.fromJson(Map<String, dynamic> json) {
    return RentalOrderDetailModel(
      id: json['id'] ?? 0,
      orderCode: json['orderCode'] ?? '',
      orderDate: json['orderDate'] ?? '',
      startDateFormatted: json['startDateFormatted'] ?? '',
      endDateFormatted: json['endDateFormatted'] ?? '',
      rentalDays: json['rentalDays'] ?? 0,
      status: json['status'] ?? 'Pending',
      shippingMethod: json['shippingMethod'] ?? '',
      receiverName: json['receiverName'] ?? '',
      receiverPhone: json['receiverPhone'] ?? '',
      notes: json['notes'] ?? json['cancelReason'] ?? 'Không có ghi chú.',
      fullAddress: json['fullAddress'] ?? '',
      rentalFee: json['rentalFee'] ?? '0.00',
      depositFee: json['depositFee'] ?? '0.00',
      shippingFee: json['shippingFee'] ?? '0.00',
      totalAmount: json['totalAmount'] ?? '0.00',
      cancelReason: json['cancelReason'],
      ownerName: json['ownerName'] ?? '',
      ownerAvatar: json['ownerAvatar'] ?? '',
      items: (json['items'] as List? ?? [])
          .map((item) => OrderDetailItem.fromJson(item))
          .toList(),
    );
  }
}

class OrderDetailItem {
  final int productId;
  final int quantity;
  final String title;
  final String image;
  final String depositAmount;
  final String pricePerDay;

  OrderDetailItem({
    required this.productId,
    required this.quantity,
    required this.title,
    required this.image,
    required this.depositAmount,
    required this.pricePerDay,
  });

  factory OrderDetailItem.fromJson(Map<String, dynamic> json) {
    return OrderDetailItem(
      productId: json['productId'] ?? 0,
      quantity: json['quantity'] ?? 0,
      title: json['title'] ?? '',
      image: json['image'] ?? '',
      depositAmount: json['depositAmount'] ?? '0.00',
      pricePerDay: json['pricePerDay'] ?? '0.00',
    );
  }
}