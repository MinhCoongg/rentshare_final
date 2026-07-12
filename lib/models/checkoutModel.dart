import 'package:rentshare_app/models/address_model.dart';

class CheckoutDataModel {
  final double walletBalance;
  final AddressModel? defaultAddress; 

  CheckoutDataModel({
    required this.walletBalance,
    this.defaultAddress,
  });

  factory CheckoutDataModel.fromJson(Map<String, dynamic> json) {
    return CheckoutDataModel(
      walletBalance: double.tryParse(json['walletBalance'].toString()) ?? 0.0,
      defaultAddress: json['defaultAddress'] != null 
          ? AddressModel.fromJson(json['defaultAddress'] as Map<String, dynamic>)
          : null,
    );
  }
}