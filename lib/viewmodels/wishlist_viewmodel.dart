import 'package:flutter/material.dart';
import 'package:rentshare_app/models/producthome_model.dart';
import '../services/wishlist_service.dart';

class WishlistProvider extends ChangeNotifier {
  List<ProductHomeModel> _wishlist = [];
  bool _isLoading = false;

  List<ProductHomeModel> get wishlist => _wishlist;
  bool get isLoading => _isLoading;

  Future<void> fetchWishlist() async {
    _isLoading = true;
    notifyListeners();

    try {
      _wishlist = await WishlistService.fetchWishlist();
    } catch (e) {
      debugPrint("Lỗi khi tải wishlist: $e");
      _wishlist = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String> toggleWishlist(int productId) async {
    try {
      String message = await WishlistService.toggleWishlist(productId);
      await fetchWishlist();
      return message;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  bool isFavorite(int productId) {
    return _wishlist.any((product) => product.id == productId);
  }

  void clearWishlist() {
    _wishlist = []; 
    notifyListeners();
  }
}