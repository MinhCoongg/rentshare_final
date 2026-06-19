import 'package:flutter/material.dart';
import 'package:rentshare_app/models/rentalOrderItem.dart';
import 'package:rentshare_app/services/rental_order_service.dart';

class RentalOrderViewModel extends ChangeNotifier {
  final RentalOrderService _orderService = RentalOrderService();

  bool _isLoading = false;
  List<RentalOrderModel> _myOrders = [];
  RentalOrderModel? _currentOrderDetail;

  bool get isLoading => _isLoading;
  List<RentalOrderModel> get myOrders => _myOrders;
  RentalOrderModel? get currentOrderDetail => _currentOrderDetail;


  Future<void> loadMyOrders({ String? status}) async {
    _isLoading = true;
    _myOrders = []; 
    notifyListeners();

    try {
      _myOrders = await _orderService.fetchMyOrders(status: status);
    } catch (e) {
      debugPrint("Lỗi loadMyOrders tại ViewModel: $e");
    } finally {
      _isLoading = false;
      notifyListeners(); 
    }
  }

 
  Future<void> loadOrderDetail({required int orderId}) async {
    _isLoading = true;
    _currentOrderDetail = null; 
    notifyListeners();

    try {
      _currentOrderDetail = await _orderService.fetchOrderDetailById(orderId: orderId);
    } catch (e) {
      debugPrint("Lỗi loadOrderDetail tại ViewModel: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}