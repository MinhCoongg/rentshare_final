class RentalOrderItemModel {
  final int productId;
  final int quantity;
  final String title;
  final String image;
  final double depositAmount;
  final double pricePerDay;

  RentalOrderItemModel({
    required this.productId,
    required this.quantity,
    required this.title,
    required this.image,
    required this.depositAmount,
    required this.pricePerDay,
  });

  factory RentalOrderItemModel.fromJson(Map<String, dynamic> json) {
    return RentalOrderItemModel(
      productId: json["productId"] ?? 0,
      quantity: json["quantity"] ?? 0,
      title: json["title"] ?? '',
      image: json["image"] ?? '',
      depositAmount: double.tryParse(json["depositAmount"]?.toString() ?? '0.0') ?? 0.0,
      pricePerDay: double.tryParse(json["pricePerDay"]?.toString() ?? '0.0') ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "productId": productId,
      "quantity": quantity,
      "title": title,
      "image": image,
      "depositAmount": depositAmount,
      "pricePerDay": pricePerDay,
    };
  }
}

class RentalOrderModel {
  final int id;
  final String orderCode;
  final String orderDate;
  final String startDate;
  final String endDate;
  final String? startDateFormatted; 
  final String? endDateFormatted;  
  final int rentalDays;
  final String status;
  final String shippingMethod;
  final String receiverName;
  final String receiverPhone;
  final String fullAddress;
  final double rentalFee;
  final double depositFee;
  final double shippingFee;
  final double totalAmount;
  final String? cancelReason;      
  final String? ownerName;         
  final String? ownerAvatar;     
  final List<RentalOrderItemModel> items;

  RentalOrderModel({
    required this.id,
    required this.orderCode,
    required this.orderDate,
    required this.startDate,
    required this.endDate,
    this.startDateFormatted,
    this.endDateFormatted,
    required this.rentalDays,
    required this.status,
    required this.shippingMethod,
    required this.receiverName,
    required this.receiverPhone,
    required this.fullAddress,
    required this.rentalFee,
    required this.depositFee,
    required this.shippingFee,
    required this.totalAmount,
    this.cancelReason,
    this.ownerName,
    this.ownerAvatar,
    required this.items,
  });

  factory RentalOrderModel.fromJson(Map<String, dynamic> json) {
    return RentalOrderModel(
      id: json["id"] ?? 0,
      orderCode: json["orderCode"] ?? '',
      orderDate: json["orderDate"] ?? '',
      startDate: json["startDate"] ?? '',
      endDate: json["endDate"] ?? '',
      startDateFormatted: json["startDateFormatted"],
      endDateFormatted: json["endDateFormatted"],
      rentalDays: json["rentalDays"] ?? 0,
      status: json["status"] ?? 'Pending',
      shippingMethod: json["shippingMethod"] ?? 'DeliverToHome',
      receiverName: json["receiverName"] ?? '',
      receiverPhone: json["receiverPhone"] ?? '',
      fullAddress: json["fullAddress"] ?? '',
      rentalFee: double.tryParse(json["rentalFee"]?.toString() ?? '0.0') ?? 0.0,
      depositFee: double.tryParse(json["depositFee"]?.toString() ?? '0.0') ?? 0.0,
      shippingFee: double.tryParse(json["shippingFee"]?.toString() ?? '0.0') ?? 0.0,
      totalAmount: double.tryParse(json["totalAmount"]?.toString() ?? '0.0') ?? 0.0,
      
      cancelReason: json["cancelReason"],
      ownerName: json["ownerName"],
      ownerAvatar: json["ownerAvatar"],
      
      items: (json["items"] as List? ?? [])
          .map((e) => RentalOrderItemModel.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "orderCode": orderCode,
      "orderDate": orderDate,
      "startDate": startDate,
      "endDate": endDate,
      "startDateFormatted": startDateFormatted,
      "endDateFormatted": endDateFormatted,
      "rentalDays": rentalDays,
      "status": status,
      "shippingMethod": shippingMethod,
      "receiverName": receiverName,
      "receiverPhone": receiverPhone,
      "fullAddress": fullAddress,
      "rentalFee": rentalFee,
      "depositFee": depositFee,
      "shippingFee": shippingFee,
      "totalAmount": totalAmount,
      "cancelReason": cancelReason,
      "ownerName": ownerName,
      "ownerAvatar": ownerAvatar,
      "items": items.map((e) => e.toJson()).toList(),
    };
  }
}