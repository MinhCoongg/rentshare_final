import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:rentshare_app/models/cart_model.dart';
import 'package:shared_preferences/shared_preferences.dart';


class RentalCartProvider extends ChangeNotifier {
  List<RentalCartItem> _items = [];
  List<RentalCartItem> get items => _items;

  static const String _cartKey = "rental_cart_key";

  RentalCartProvider() {
    loadCartFromStorage(); 
  }


  Future<void> loadCartFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_cartKey);
      if (jsonString == null) return;

      final List decoded = jsonDecode(jsonString);
      _items = decoded.map((e) => RentalCartItem.fromJson(e)).toList();
      notifyListeners();
    } catch (e) {
      debugPrint("Lỗi load giỏ hàng ní ơi: $e");
    }
  }


  Future<void> saveCartToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(_items.map((e) => e.toJson()).toList());
    await prefs.setString(_cartKey, jsonString);
  }

  Future<String> addToCart(RentalCartItem item) async {
    if (_items.isNotEmpty && _items.first.ownerId != item.ownerId) {
      return 'DIFFERENT_SHOP'; 
    }

    final index = _items.indexWhere((e) => e.productId == item.productId);

    if (index != -1) {
      _items[index].quantity += item.quantity; 
    } else {
      _items.add(item); 
    }

    await saveCartToStorage();
    notifyListeners();
    return 'SUCCESS';
  }


  Future<void> clearAndAddNewProduct(RentalCartItem item) async {
    _items.clear();
    _items.add(item);
    await saveCartToStorage();
    notifyListeners();
  }


  Future<bool> increaseQuantityWithCheck(int productId, int maxStock) async {
    final index = _items.indexWhere((e) => e.productId == productId);
    if (index != -1) {
      if (_items[index].quantity >= maxStock) {
        return false; 
      }
      _items[index].quantity++;
      await saveCartToStorage();
      notifyListeners();
      return true; 
    }
    return false;
  }


  Future<void> decreaseQuantity(int productId) async {
    final index = _items.indexWhere((e) => e.productId == productId);
    if (index != -1) {
      if (_items[index].quantity > 1) {
        _items[index].quantity--;
      } else {
        _items.removeAt(index); 
      }
      await saveCartToStorage();
      notifyListeners();
    }
  }

  
  double get totalDeposit {
    return _items.fold(0.0, (sum, item) => sum + (item.depositAmount * item.quantity));
  }

 
  double get totalRentalFeePerDay {
    return _items.fold(0.0, (sum, item) => sum + (item.pricePerDay * item.quantity));
  }

 Future<void> removeFromCart(int productId) async {
    final index = _items.indexWhere((e) => e.productId == productId);
    if (index != -1) {
      _items.removeAt(index); 
      await saveCartToStorage();
      notifyListeners(); 
    }
  }

  Future<void> clearCart() async {
    _items.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cartKey);
    notifyListeners();
  }
}