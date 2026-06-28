import 'package:flutter/material.dart';
import 'package:rentshare_app/models/producthome_model.dart';
import 'package:rentshare_app/services/product_services.dart';

class ProductListViewModel extends ChangeNotifier {
  final ProductDetailService _productService = ProductDetailService();

  List<ProductHomeModel> _products = [];
  bool _isLoading = false;

  List<ProductHomeModel> get products => _products;
  bool get isLoading => _isLoading;


  String? currentSortBy;
  int? selectedCategoryId; 
  String? currentLocation;
  String? currentKeyword; 

  Future<void> loadProducts({
    int? categoryId, 
    double? priceMin, 
    double? priceMax, 
    String? location, 
    String? sortBy,
    String? keyword, 
    bool clearFilters = false, 
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (clearFilters) {
        resetFilters();
      }
      if (categoryId != null) selectedCategoryId = categoryId;
      if (keyword != null) currentKeyword = keyword;
      if (sortBy != null) currentSortBy = sortBy;
      if (location != null) currentLocation = location;

      if (currentKeyword != null && currentKeyword!.isNotEmpty) {
        selectedCategoryId = null; 
      }

      final filters = {
        if (selectedCategoryId != null) 'categoryId': selectedCategoryId,
        if (priceMin != null) 'priceMin': priceMin,
        if (priceMax != null) 'priceMax': priceMax,
        if (currentLocation != null && currentLocation!.isNotEmpty) 'location': currentLocation,
        if (currentSortBy != null) 'sortBy': currentSortBy,
        if (currentKeyword != null && currentKeyword!.isNotEmpty) 'keyword': currentKeyword, 
      };

      _products = await _productService.fetchFilteredProducts(filters);
    } catch (e) {
      debugPrint("Lỗi load sản phẩm trong ViewModel: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  void resetFilters() {
    selectedCategoryId = null;
    currentSortBy = null;
    currentLocation = null;
    currentKeyword = null;
    notifyListeners();
  }

}