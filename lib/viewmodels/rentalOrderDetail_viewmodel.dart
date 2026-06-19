import 'package:flutter/material.dart';
import 'package:rentshare_app/models/rentalOrderDetail.dart';
import 'package:rentshare_app/services/rental_order_service.dart';

class RentalOrderDetailViewModel extends ChangeNotifier {
  final RentalOrderService _orderService = RentalOrderService();
  
  RentalOrderDetailModel? _orderDetail;
  bool _isLoading = false;
  String _errorMessage = '';

  RentalOrderDetailModel? get orderDetail => _orderDetail;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<void> loadOrderDetail(int orderId) async {
    _isLoading = true;
    _errorMessage = '';
    _orderDetail = null;
    notifyListeners(); 

    try {
      final result = await _orderService.fetchOrderDetail(orderId);
      if (result != null) {
        _orderDetail = result;
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
}