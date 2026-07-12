import 'package:flutter/material.dart';
import 'package:rentshare_app/models/product_model.dart';
import 'package:rentshare_app/services/product_services.dart';

class ProductDetailViewModel extends ChangeNotifier {
  ProductModel? _product;
  bool _isLoading = false;
  String? _errorMessage;
  int _currentImageIndex = 0;

  ProductModel? get product => _product;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get currentImageIndex => _currentImageIndex;

  void updateImageIndex(int index) {
    _currentImageIndex = index;
    notifyListeners();
  }

  Future<void> loadProductDetail(int productId) async {
    _isLoading = true;
    _errorMessage = null;
    _product = null;
    notifyListeners();

    try {
      final result = await ProductDetailService.fetchProductDetail(productId);

      if (result != null) {
        _product = result; 
      } else {
        _errorMessage = "Không thể lấy thông tin sản phẩm hoặc dữ liệu bị lỗi!";
      }
    } catch (e) {
      _errorMessage = "Lỗi xử lý ViewModel: $e";
    } finally {
      _isLoading = false;
      notifyListeners(); 
    }
  }
}