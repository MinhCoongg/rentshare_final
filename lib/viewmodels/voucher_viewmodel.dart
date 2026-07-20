import 'package:flutter/material.dart';
import 'package:rentshare_app/models/voucher_model.dart';
import 'package:rentshare_app/services/voucher_service.dart';


class VoucherViewModel extends ChangeNotifier {
  final VoucherService _voucherService = VoucherService();
  
  List<Voucher> _vouchers = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Voucher> get vouchers => _vouchers;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadVouchers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners(); 

    try {
      _vouchers = await _voucherService.fetchAvailableVouchers();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners(); 
    }
  }


  Voucher? _selectedVoucher;
  Voucher? get selectedVoucher => _selectedVoucher;

  void selectVoucher(Voucher voucher) {
    _selectedVoucher = voucher;
    notifyListeners();
  }
}