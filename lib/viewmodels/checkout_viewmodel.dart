import 'package:flutter/material.dart';
import 'package:rentshare_app/models/address_model.dart';
import 'package:rentshare_app/models/cart_model.dart';
import 'package:rentshare_app/models/orderRequest_model.dart';
import 'package:rentshare_app/models/tierPerDay_model.dart';
import 'package:rentshare_app/models/voucher_model.dart';
import 'package:rentshare_app/services/address_services.dart';
import 'package:rentshare_app/services/bookdateProduct_service.dart'; 
import 'package:rentshare_app/services/checkout_service.dart';

class CheckoutViewModel extends ChangeNotifier {
  final CheckoutService _checkoutService = CheckoutService();

  bool _isLoading = true;
  double _walletBalance = 0.0;
  AddressModel? _defaultAddress; 
  String _deliveryMethod = 'Shipping'; 
  DateTimeRange? _selectedDateRange;
  List<AddressModel> _userAddresses = [];
  List<String> _bookedDates = [];
  List<RentalCartItem> _currentCartItems = [];
  List<RentalCartItem> get cartitem => _currentCartItems;
  Voucher? _appliedVoucher; 
  double _discountAmount = 0.0;
  double get discountAmount => _discountAmount;
  Voucher? get appliedVoucher => _appliedVoucher;
  bool get isLoading => _isLoading;
  double get walletBalance => _walletBalance;
  AddressModel? get defaultAddress => _defaultAddress; 
  String get deliveryMethod => _deliveryMethod;
  DateTimeRange? get selectedDateRange => _selectedDateRange;
  List<AddressModel> get userAddresses => _userAddresses; 
  
  List<String> get bookedDates => _bookedDates;

  int get rentalDays {
    if (_selectedDateRange == null) return 0;
    int days = _selectedDateRange!.end.difference(_selectedDateRange!.start).inDays;
    return days == 0 ? 1 : days;
  }

  double getRentalFeeOfItem(RentalCartItem item) {
    int days = rentalDays;
    if (days == 0) return 0;

    double pricePerDay = item.pricePerDay;

    if (item.tierPricings.isNotEmpty) {
      List<TierPricingModel> sortedTiers = List.from(item.tierPricings);
      sortedTiers.sort((a, b) => b.minDays.compareTo(a.minDays));
      for (var tier in sortedTiers) {
        if (days >= tier.minDays) {
          pricePerDay = tier.pricePerDay;
          break;
        }
      }
    }
    return pricePerDay * days * item.quantity;
  }

  double calculateTotalRentalFee(List<RentalCartItem> cartItems) {
    double total = 0.0;
    for (var item in cartItems) {
      total += getRentalFeeOfItem(item);
    }
    return total;
  }

  double getShippingFee() {
    return (_deliveryMethod == 'Shipping') ? 30000.0 : 0.0;
  }

  
  void setCartItems(List<RentalCartItem> items) {
    _currentCartItems = items;
  }

  Future<void> fetchCheckoutData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _checkoutService.getCheckoutInfo();
      if (result != null) _walletBalance = result.walletBalance;

      final addressesResult = await AddressService.fetchUserAddresses();
      _userAddresses = addressesResult;

      if (_userAddresses.isNotEmpty) {
        _defaultAddress = _userAddresses.firstWhere(
          (addr) => addr.isDefault == 1 || addr.isDefault == true,
          orElse: () => _userAddresses.first,
        );
      } else {
        _defaultAddress = null;
      }


      _bookedDates.clear();
      if (_currentCartItems.isNotEmpty) {
        List<int> productIds = _currentCartItems.map((e) => e.productId).toList();
        _bookedDates = await BookDateProduct.fetchBookedDates(productIds);
      }

    } catch (e) {
      debugPrint("Lỗi fetch dữ liệu Checkout: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setDateRange(DateTimeRange range) {
    _selectedDateRange = range;
    notifyListeners();
  }

  void setDeliveryMethod(String method) {
    _deliveryMethod = method;
    notifyListeners();
  }

  void selectAddressFromBook(AddressModel chosenAddress) {
    _defaultAddress = chosenAddress;
    notifyListeners();
  }


  
  Future<bool> createOrder(List<RentalCartItem> cartItems) async {
    if (_selectedDateRange == null || _defaultAddress == null) return false;
    _isLoading = true;
    notifyListeners();

    try {
      String startStr = "${_selectedDateRange!.start.year}-${_selectedDateRange!.start.month.toString().padLeft(2, '0')}-${_selectedDateRange!.start.day.toString().padLeft(2, '0')}";
      String endStr = "${_selectedDateRange!.end.year}-${_selectedDateRange!.end.month.toString().padLeft(2, '0')}-${_selectedDateRange!.end.day.toString().padLeft(2, '0')}";
      double rentalFee = calculateTotalRentalFee(cartItems);
      double shippingFee = getShippingFee();
      
      double depositFee = 0.0;
      for (var item in cartItems) {
        depositFee += (item.depositAmount * item.quantity);
      }
      
      double totalAmount = rentalFee + shippingFee + depositFee;
      double discount = _appliedVoucher != null ? _discountAmount : 0.0;
      double finalTotalAmount = totalAmount - discount;
      String dbShippingMethod = (_deliveryMethod == 'Shipping') 
          ? 'DeliverToHome' 
          : 'SelfPickUp';
      RentalOrderRequestModel orderRequest = RentalOrderRequestModel(
        startDate: startStr,
        endDate: endStr,
        shippingMethod: dbShippingMethod,
        receiverName: _defaultAddress!.receiverName,
        receiverPhone: _defaultAddress!.receiverPhone,
        fullAddress: _defaultAddress!.fullAddress,
        shippingFee: shippingFee,
        rentalFee: rentalFee,
        depositFee: depositFee,
        totalAmount: finalTotalAmount,
        items: cartItems,
        voucherId: _appliedVoucher?.id,
        discountAmount: discount,
      );

      final res = await _checkoutService.submitRentalOrder(
        orderData: orderRequest, 
      );

      if (res != null && res['success'] == true) {
        return true;
      } else {
        debugPrint("Đặt đơn thất bại từ hệ thống: ${res?['message']}");
        return false;
      }

    } catch (e) {
      debugPrint("Lỗi xử lý tạo đơn tại ViewModel: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshWalletData() async {
      try {
        await fetchCheckoutData();
      } catch (e) {
        debugPrint("Lỗi cập nhật số dư: $e");
      }
  }

  

  void applyVoucher(Voucher voucher) {
    _appliedVoucher = voucher;
    _discountAmount = _calculateDiscountValue();
    notifyListeners(); 
  }


  void removeVoucher() {
    _appliedVoucher = null;
    notifyListeners();
  }


  double _calculateDiscountValue() {
    if (_appliedVoucher == null) return 0.0;
    
    double rentalFee = calculateTotalRentalFee(_currentCartItems);
    double shippingFee = getShippingFee();
    double currentTotal = rentalFee + shippingFee; 

    if (_appliedVoucher!.discountType == 'PERCENT') {
      double discount = (currentTotal * _appliedVoucher!.discountValue) / 100;
      return discount > _appliedVoucher!.maxDiscountAmount ? _appliedVoucher!.maxDiscountAmount : discount;
    } else {
      return _appliedVoucher!.discountValue;
    }
  }


  void resetCheckout() {
    _appliedVoucher = null;
    _selectedDateRange = null;
    _deliveryMethod = 'Shipping';
  }

}