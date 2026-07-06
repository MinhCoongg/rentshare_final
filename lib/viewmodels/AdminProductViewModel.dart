import 'package:flutter/material.dart';
import 'package:rentshare_app/models/adminProduct.dart';
import 'package:rentshare_app/models/adminmanager.dart';
import '../services/ProductAdminService.dart';

class AdminProductViewModel extends ChangeNotifier {
  final _service = ProductAdminService();

  List<Adminproduct> products = [];
  bool isLoading = false;
  Map<String, int> stats = {'Pending': 0, 'Available': 0, 'Hidden': 0, 'Total': 0};
  String _currentStatus = '';
  String _currentSearch = '';



  List<RentalOrder> _orders = [];
  Map<String, int> _statsus = {
    'totalOrders': 0, 
    'pendingOrders': 0, 
    'rentingOrders': 0, 
    'completedOrders': 0, 
    'cancelledOrders': 0
  };
  int _currentPage = 1;
  int get currentPage => _currentPage;
  String _selectedStatus = '';
  List<RentalOrder> get orders => _orders;
  Map<String, int> get statsus => _statsus;
  String get selectedStatus => _selectedStatus;





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

  Future<void> loadOrders({String? status, String? search, int? page}) async {
    if (status != null) _selectedStatus = status;
    if (search != null) _currentSearch = search;
    if (page != null) _currentPage = page;
    
    isLoading = true;
    notifyListeners(); 

    try {
     final result = await _service.fetchOrdersData(
        _selectedStatus == 'All' ? '' : _selectedStatus, 
        _currentSearch, 
        _currentPage
      );
      _orders = result['data'];
      _statsus = result['stats'];
    } catch (e) {
      _orders = [];
      debugPrint("Lỗi loadOrders: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
}

  Future<void> filterOrderByStatus(String status) async {
    _currentPage = 1; 
    await loadOrders(status: status);
  }

  Future<void> searchOrders(String query) async {
    _currentPage = 1;
    await loadOrders(search: query);
  }


  int get totalPages {
    int total = 0;
    if (_selectedStatus == 'Pending') total = statsus['pendingOrders'] ?? 0;
    else if (_selectedStatus == 'Delivered') total = statsus['rentingOrders'] ?? 0;
    else if (_selectedStatus == 'Completed') total = statsus['completedOrders'] ?? 0;
    else if (_selectedStatus == 'Cancelled') total = statsus['cancelledOrders'] ?? 0;
    else total = statsus['totalOrders'] ?? 0; 
    return (total / 5).ceil(); 
  }
}