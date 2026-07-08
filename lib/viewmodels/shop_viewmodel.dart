import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentshare_app/models/productShop.dart';
import 'package:rentshare_app/models/producthome_model.dart';
import 'package:rentshare_app/services/shop_service.dart';
import 'package:rentshare_app/utils/sharetoken_utils.dart';
import 'package:rentshare_app/viewmodels/home_viewmodel.dart';

class ShopViewModel extends ChangeNotifier {
  ShopDetailModel? _shopDetail; 
  bool _isLoading = false;

  List<ProductHomeModel> _products = [];
  String? _errorMessage;

  List<ProductHomeModel> get products => _products;
  String? get errorMessage => _errorMessage;

  ShopDetailModel? get shopDetail => _shopDetail;
  bool get isLoading => _isLoading;

  Future<void> loadShopDetail(int shopId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _shopDetail = await ShopService.fetchShopDetail(shopId);
    } catch (e) {
      debugPrint("Lỗi: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  Future<void> fetchProducts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final String token =await SharedPrefsUtils.getToken();
      _products = await ShopService.getMyProducts(token);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Dùng để ẩn hocwj hiển sp của shop
  Future<void> toggleStatus(int productId, String currentStatus, BuildContext context) async {
    if (currentStatus != 'Available' && currentStatus != 'Hidden') {
      debugPrint("Không thể ẩn/hiện sản phẩm đang trong trạng thái: $currentStatus");
      return;
    }
    String newStatus = (currentStatus == 'Available') ? 'Hidden' : 'Available';
    final String token =await SharedPrefsUtils.getToken();
    try {
      bool success = await ShopService.toggleStatus(token, productId, newStatus);
      if (success) {
        final index = _products.indexWhere((p) => p.id == productId);
        if (index != -1) {
          _products[index] = ProductHomeModel(
            id: _products[index].id,
            ownerId: _products[index].ownerId,
            categoryId: _products[index].categoryId,
            addressId: _products[index].addressId,
            title: _products[index].title,
            depositAmount: _products[index].depositAmount,
            minPrice: _products[index].minPrice,
            quantity: _products[index].quantity,
            status: newStatus, // Cập nhật status mới
            createdAt: _products[index].createdAt,
            location: _products[index].location,
            images: _products[index].images,
            rating: _products[index].rating,
            reviewCount: _products[index].reviewCount,
          );
          notifyListeners(); // Báo UI vẽ lại cái nút "Ẩn/Hiện"
        }
          ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Cập nhật trạng thái thành công!"), backgroundColor: Colors.green),
        );
        Provider.of<HomeViewModel>(context, listen: false).fetchProducts();
      }else{
          ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Sản phẩm này Admin không duyệt cho bạn!"), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      debugPrint("Lỗi toggle status: $e");
      debugPrint("LỖI CỰC GẮT: $e");
    }
  }
}