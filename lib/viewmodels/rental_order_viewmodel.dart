import 'dart:io';
import 'package:flutter/material.dart';
import 'package:rentshare_app/models/damageReport.dart';
import 'package:rentshare_app/models/policy_model.dart';
import 'package:rentshare_app/models/rentalOrderDetail.dart';
import 'package:rentshare_app/models/rentalOrderItem.dart'; 
import 'package:rentshare_app/services/rental_order_service.dart';


class RentalOrderViewModel extends ChangeNotifier {
  final RentalOrderService _orderService = RentalOrderService();
  
  bool _isLoading = false;
  String _errorMessage = '';
  List<RentalOrderModel> _myOrders = [];   
  List<RentalOrderModel> _ownerOrders = [];                     
  RentalOrderDetailModel? _currentOrder;              
  DamageReport? _damageReport;

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  List<RentalOrderModel> get myOrders => _myOrders;
  List<RentalOrderModel> get ownerOrders => _ownerOrders;
  RentalOrderDetailModel? get currentOrder => _currentOrder;
  DamageReport? get damageReport => _damageReport;

 
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


  Future<Map<String, dynamic>> approveRequest(int orderId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final success = await _orderService.approveRentalRequest(orderId);
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

}