import 'package:flutter/material.dart';
import 'package:rentshare_app/models/adminProduct.dart';
import '../services/ProductAdminService.dart';

class AdminProductViewModel extends ChangeNotifier {
  final _service = ProductAdminService();
  
  List<Adminproduct> products = [];
  bool isLoading = false;
  
  Map<String, int> stats = {'Pending': 0, 'Available': 0, 'Hidden': 0, 'Total': 0};
  

  String _currentStatus = '';
  String _currentSearch = '';

  String get selectedStatus => _currentStatus;


  Future<void> filterByStatus(String status) async {
    await loadProducts(status, search: _currentSearch);
  }

  Future<void> searchProducts(String query) async {
    await loadProducts(_currentStatus, search: query);
  }

  Future<void> loadProducts(String status, {String? search}) async {
    _currentStatus = status;
    if (search != null) _currentSearch = search;
    
    isLoading = true;
    notifyListeners();

    try {
      products = await _service.fetchProducts(_currentStatus, _currentSearch);
      final allProducts = await _service.fetchProducts('', ''); 
      stats['Pending'] = allProducts.where((p) => p.status == 'Pending').length;
      stats['Available'] = allProducts.where((p) => p.status == 'Available').length;
      stats['Hidden'] = allProducts.where((p) => p.status == 'Hidden').length;
      stats['Total'] = allProducts.length;
      
    } catch (e) {
      debugPrint("Lỗi tải danh sách: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }


  Future<void> approveOrReject(int productId, String newStatus, String currentStatus) async {
    bool success = await _service.updateStatus(productId, newStatus);
    if (success) {
      // Sau khi cập nhật xong, load lại đúng cái status cũ đang lọc
      await loadProducts(_currentStatus, search: _currentSearch);
    }
  }
}