import 'package:rentshare_app/models/cart_model.dart';

class RentalOrderRequestModel {
  final String startDate;
  final String endDate;
  final String shippingMethod;
  final String receiverName;
  final String receiverPhone;
  final String fullAddress;
  final double shippingFee;
  final double rentalFee;
  final double depositFee;
  final double totalAmount;
  final List<RentalCartItem> items;

  RentalOrderRequestModel({
    required this.startDate,
    required this.endDate,
    required this.shippingMethod,
    required this.receiverName,
    required this.receiverPhone,
    required this.fullAddress,
    required this.shippingFee,
    required this.rentalFee,
    required this.depositFee,
    required this.totalAmount,
    required this.items,
  });

  Map<String, dynamic> toJson() {
    return {
      "startDate": startDate,
      "endDate": endDate,
      "shippingMethod": shippingMethod,
      "receiverName": receiverName,
      "receiverPhone": receiverPhone,
      "fullAddress": fullAddress,
      "shippingFee": shippingFee,
      "rentalFee": rentalFee,
      "depositFee": depositFee,
      "totalAmount": totalAmount,
      "items": items.map((e) => {
        "productId": e.productId,
        "quantity": e.quantity,
        "rentalFeeSnapshot": e.pricePerDay, 
        "depositFeeSnapshot": e.depositAmount, 
      }).toList(),
    };
  }
}