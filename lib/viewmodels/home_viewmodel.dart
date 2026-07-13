import 'package:flutter/material.dart';
import 'package:rentshare_app/models/category_model.dart';
import 'package:rentshare_app/models/producthome_model.dart'; // File này chứa cả ProductHomeModel và ShopHomeModel của ní
import 'package:rentshare_app/models/shop_model.dart';
import 'package:rentshare_app/services/home_services.dart';
import 'package:rentshare_app/services/product_services.dart'; 

class HomeViewModel extends ChangeNotifier {
  final HomeService _homeService = HomeService();
  final ProductDetailService _productService = ProductDetailService(); 

  List<CategoryModel> _categories = [];
  bool _isLoading = false;


  List<ProductHomeModel> _featuredProducts = [];
  List<ProductHomeModel> _newestProducts = [];
  List<ProductHomeModel> _suggestedProducts = [];

  

  List<ProductHomeModel> _searchResults = [];
  List<CategoryModel> get categories => _categories;

  bool get isLoading => _isLoading;
  
  List<ProductHomeModel> get featuredProducts => _featuredProducts;
  List<ProductHomeModel> get newestProducts => _newestProducts;
  List<ProductHomeModel> get suggestedProducts => _suggestedProducts;

  Future<void> fetchCategories() async {
    _isLoading = true;
    notifyListeners(); 

    try {
      final result = await _homeService.getCategoryTree();
      _categories = result; 
    } catch (e) {
      debugPrint('Lỗi fetchCategories trong ViewModel: $e');
    }

    _isLoading = false;
    notifyListeners(); 
  }

 
  Future<void> fetchProducts() async {
    _isLoading = true;
    notifyListeners();

    try {
      final resultMap = await _homeService.getHomePageProducts();
      
      _featuredProducts = resultMap['featured'] ?? [];
      _newestProducts = resultMap['newest'] ?? [];
      _suggestedProducts = resultMap['suggested'] ?? [];
      
    } catch (e) {
      debugPrint('Lỗi fetchProducts trong ViewModel: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> searchProducts(String keyword) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _searchResults = await _productService.fetchFilteredProducts({'keyword': keyword});
    } catch (e) {
      debugPrint("Lỗi tìm kiếm: $e");
    }
    
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> hasAnyProduct() async {
    final products = await _productService.fetchMyProducts(); 
    debugPrint('$products');
    return products.isNotEmpty;
  }
  
}