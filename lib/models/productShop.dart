import 'package:rentshare_app/models/producthome_model.dart';

class ShopDetailModel {
  final ShopInfo shopInfo;
  final List<ProductHomeModel> products;

  ShopDetailModel({required this.shopInfo, required this.products});

  factory ShopDetailModel.fromJson(Map<String, dynamic> json) {
    var list = json['products'] as List;
    List<ProductHomeModel> productList = list.map((i) => ProductHomeModel.fromJson(i)).toList();

    return ShopDetailModel(
      shopInfo: ShopInfo.fromJson(json['shopInfo']),
      products: productList,
    );
  }
}

class ShopInfo {
  final String shopName;
  final String? shopAvatar;
  final double shopRating;
  final int totalRentals;

  ShopInfo({required this.shopName, this.shopAvatar, required this.shopRating, required this.totalRentals});

  factory ShopInfo.fromJson(Map<String, dynamic> json) {
    return ShopInfo(
      shopName: json['shopName'],
      shopAvatar: json['shopAvatar'],
      shopRating: double.parse(json['shopRating'].toString()),
      totalRentals: int.parse(json['totalRentals'].toString()),
    );
  }
}