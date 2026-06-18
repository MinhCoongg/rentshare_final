import 'package:flutter/material.dart';
import 'package:rentshare_app/models/address_model.dart';
import 'package:rentshare_app/models/tierPerDay_model.dart';
import 'package:rentshare_app/services/address_services.dart'; 
import 'package:rentshare_app/services/checkout_service.dart';
import 'package:rentshare_app/services/pricing_service.dart';

class CheckoutViewModel extends ChangeNotifier {
  final CheckoutService _checkoutService = CheckoutService();

  bool _isLoading = true;
  double _walletBalance = 0.0;
  AddressModel? _defaultAddress; 
  String _deliveryMethod = 'Shipping'; 
  DateTimeRange? _selectedDateRange;

  List<AddressModel> _userAddresses = [];
  List<TierPricingModel> _productTiers = [];

  
  

  bool get isLoading => _isLoading;
  double get walletBalance => _walletBalance;
  AddressModel? get defaultAddress => _defaultAddress; 
  String get deliveryMethod => _deliveryMethod;
  DateTimeRange? get selectedDateRange => _selectedDateRange;
  List<AddressModel> get userAddresses => _userAddresses; 
  List<TierPricingModel> get productTiers => _productTiers; 
  

  int get rentalDays {
    if (_selectedDateRange == null) return 0;
    int days = _selectedDateRange!.end.difference(_selectedDateRange!.start).inDays;
    return days == 0 ? 1 : days;
  }

  double getApplicablePricePerDay(double basePricePerDay) {
    int days = rentalDays;
    if (days == 0 || _productTiers.isEmpty) return basePricePerDay;

    List<TierPricingModel> sortedTiers = List.from(_productTiers);
    sortedTiers.sort((a, b) => b.minDays.compareTo(a.minDays));

    for (var tier in sortedTiers) {
      if (days >= tier.minDays) {
        return tier.pricePerDay; 
      }
    }
    return basePricePerDay; 
  }

  double getRentalFee(double basePricePerDay) {
    return getApplicablePricePerDay(basePricePerDay) * rentalDays;
  }

  double getShippingFee() {
    return (_deliveryMethod == 'Shipping') ? 30000.0 : 0.0;
  }

  double getTotalAmount(double basePricePerDay, double totalDeposit) {
    return getRentalFee(basePricePerDay) + totalDeposit + getShippingFee();
  }


  Future<void> fetchCheckoutData(int productId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _checkoutService.getCheckoutInfo();
      if (result != null) {
        _walletBalance = result.walletBalance;
      }
    } catch (e) {
      debugPrint("Lỗi API bốc thông tin ví: $e");
    }
    

    try {
      final tiersResult = await TierService.fetchProductTiers(productId);
      _productTiers = tiersResult;
    } catch (e) {
      debugPrint("Lỗi API bốc bảng bậc giá sản phẩm: $e");
    }


    try {
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
    } catch (e) {
      debugPrint("Lỗi API bốc sổ địa chỉ người nhận (Dính chặn 401): $e");
      _defaultAddress = null; 
    }
    
    _isLoading = false;
    notifyListeners();
  }

  void setDateRange(DateTimeRange range) {
    _selectedDateRange = range;
    notifyListeners();
  }

  void setDeliveryMethod(String method) {
    _deliveryMethod = method;
    notifyListeners();
  }

  bool isWalletBalanceEnough(double totalAmount) {
    return _walletBalance >= totalAmount;
  }

 
  void selectAddressFromBook(AddressModel chosenAddress) {
    _defaultAddress = chosenAddress;
    notifyListeners();
  }
}