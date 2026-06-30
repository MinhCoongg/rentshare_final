import 'dart:io';
import 'package:flutter/material.dart';
import 'package:rentshare_app/models/damageReport.dart';
import 'package:rentshare_app/models/policy_model.dart';
import 'package:rentshare_app/models/productSelection.dart';
import 'package:rentshare_app/models/rentalOrderDetail.dart';
import 'package:rentshare_app/services/rental_order_service.dart';


class RentalOrderViewModel extends ChangeNotifier {
  final RentalOrderService _orderService = RentalOrderService();
  
  bool _isLoading = false;
  String _errorMessage = '';
  List<RentalOrderDetailModel> _myOrders = [];   
  List<RentalOrderDetailModel> _ownerOrders = [];                     
  RentalOrderDetailModel? _currentOrder;              
  DamageReport? _damageReport;

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  List<RentalOrderDetailModel> get myOrders => _myOrders;
  List<RentalOrderDetailModel> get ownerOrders => _ownerOrders;
  RentalOrderDetailModel? get currentOrder => _currentOrder;
  DamageReport? get damageReport => _damageReport;
  Map<int, ProductSelectionState> selectedProducts = {};
 
  Future<void> loadMyOrders({String? status}) async {
    _isLoading = true;
    _myOrders = []; 
    _errorMessage = '';
    notifyListeners();

    try {
      _myOrders = await _orderService.fetchMyOrders(status: status);
    } catch (e) {
      _errorMessage = "Lỗi tải danh sách đơn: ${e.toString()}";
      debugPrint("Lỗi loadMyOrders tại ViewModel: $e");
    } finally {
      _isLoading = false;
      notifyListeners(); 
    }
  }


 

 
  Future<void> loadOrderDetailFull(int orderId) async {
    _isLoading = true;
    _errorMessage = '';
    _currentOrder = null;
    notifyListeners(); 

    try {
      final result = await _orderService.fetchOrderDetail(orderId);
      if (result != null) {
        _currentOrder = result;
      } else {
        _errorMessage = "Không thể tải thông tin chi tiết đơn hàng này";
      }
    } catch (e) {
      _errorMessage = "Lỗi hệ thống: ${e.toString()}";
    } finally {
      _isLoading = false;
      notifyListeners(); 
    }
  }

  
  Future<Map<String, dynamic>> cancelOrder(int orderId) async {
    _isLoading = true;
    notifyListeners(); 
    try {
      final result = await _orderService.cancelRentalOrder(orderId);
      return result;
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    } finally {
      _isLoading = false;
      notifyListeners(); 
    }
  }

 
  Future<void> getOrderDetailById(int orderId) async {
    _isLoading = true;
    _errorMessage = '';
    _currentOrder = null;
    notifyListeners();

    try {
      final result = await _orderService.fetchOrderDetailForOwner(orderId);
      if (result != null) {
        _currentOrder = result;
        initSelection(_currentOrder!.items);
      } else {
        _errorMessage = "Không thể bốc dữ liệu chi tiết đơn hàng này";
      }
    } catch (e) {
      _errorMessage = "Lỗi kết nối: ${e.toString()}";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }



  void initSelection(List<OrderDetailItem> items) {
    selectedProducts.clear();
    for (var item in items) {
      selectedProducts[item.productId] = ProductSelectionState(); 
    }
    notifyListeners();
  }


  Future<Map<String, dynamic>> approveRequest(int orderId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final rejectedItems = getProcessedItems(); 
      
      // 1. Gửi đi duyệt
      final success = await _orderService.approveRentalRequest(orderId, rejectedItems);
      
      if (success) {
        // 2. QUAN TRỌNG: Load lại danh sách đơn hàng sau khi duyệt thành công
        // Ní phải load lại để lấy dữ liệu mới nhất từ Server (đã loại món bị hủy)
        await loadOwnerOrders(status: 'Pending'); 
      }
      
      return {'success': success};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
}

  
  Future<Map<String, dynamic>> rejectRequest({required int rentalRequestId, required String cancelReason}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final success = await _orderService.rejectRentalRequest(rentalRequestId, cancelReason);
      return {'success': success};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadOwnerOrders({String? status}) async {
    _isLoading = true;
    _ownerOrders = []; 
    _errorMessage = '';
    notifyListeners(); 

    try {
      _ownerOrders = await _orderService.fetchOwnerOrders(status: status);
    } catch (e) {
      _errorMessage = "Lỗi tải danh sách đơn chủ shop: ${e.toString()}";
      debugPrint("Lỗi loadOwnerOrders tại ViewModel: $e");
    } finally {
      _isLoading = false;
      notifyListeners(); 
    }
  }

  
  Future<Map<String, dynamic>> submitReturnFromRenter(int orderId, File imageFile, String tracking, String note) async {
    _isLoading = true;
    notifyListeners();
    try {
      // 🚀 Truyền trực tiếp File ảnh xuống Service, không cần gọi uploadReturnProof nữa
      final success = await _orderService.renterRequestReturn(orderId, imageFile, tracking, note);
      return {'success': success};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<PolicyModel>> fetchPolicies(int productId) async {
    return await _orderService.fetchPolicies(productId);
  }

  Future<bool> sendDamageReport(int id, String note, double fee, File? img) async {
    _isLoading = true; notifyListeners();
    final result = await _orderService.reportDamage(id, note, fee, img);
    _isLoading = false; notifyListeners();
    return result['success'] == true;
  }

  Future<void> fetchDamageReport(int rentalRequestId) async {
    _isLoading = true;
    notifyListeners(); 

    try {
      _damageReport = await _orderService.getDamageReport(rentalRequestId);
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint("Lỗi ViewModel: $e");
    } finally {
      _isLoading = false;
      notifyListeners(); 
    }
  }


  Future<DamageReport?> fetchDamageReportDirect(int rentalRequestId) async {
    try {



      _damageReport = await _orderService.getDamageReport(rentalRequestId);
      
      
      return _damageReport; 
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return null; 
    }
  }


  Future<Map<String, dynamic>> acceptDamageReport(int orderId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final result = await _orderService.acceptDamageReport(orderId);
      return result;
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  int getCountByStatus(String status) {
    return _myOrders.where((order) => order.status == status).length;
  }




  void toggleProductSelection(int productId, bool isSelected) {
    if (selectedProducts[productId] == null) {
      selectedProducts[productId] = ProductSelectionState();
    }
    selectedProducts[productId]!.isSelected = isSelected;
    notifyListeners();
  }

  // 2. Hàm lưu lý do
  void setReasonForProduct(int productId, String reason) {
    if (selectedProducts[productId] == null) {
      selectedProducts[productId] = ProductSelectionState();
    }
    selectedProducts[productId]!.reason = reason;
    notifyListeners();
  }

  // 3. Hàm lưu ghi chú
  void setNoteForProduct(int productId, String note) {
    if (selectedProducts[productId] == null) {
      selectedProducts[productId] = ProductSelectionState();
    }
    selectedProducts[productId]!.note = note;
    notifyListeners();
  }


  List<Map<String, dynamic>> getProcessedItems() {
    List<Map<String, dynamic>> itemsToSend = [];
    selectedProducts.forEach((productId, state) {
      if (state.isSelected == false) {
        itemsToSend.add({
          'productId': productId,
          'reason': state.reason,
          'note': state.note,
        });
      }
    });
    
    return itemsToSend;
  }
  
}