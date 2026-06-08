import 'package:flutter/material.dart';
import 'package:rentshare_app/services/api_services.dart';
import '../models/product_model.dart';

class ProductDetailViewModel extends ChangeNotifier {
  ProductModel? product;
  bool isLoading = false;
  String? error;

  Future<void> fetchProductDetail(int id) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final data = await ApiService.getProductById(id);
      product = ProductModel.fromJson(data['data']);
    } catch (e) {
      error = e.toString();
      debugPrint("Lỗi gọi API: $e");
    }

    isLoading = false;
    notifyListeners();
  }
}