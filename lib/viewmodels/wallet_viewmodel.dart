import 'package:flutter/material.dart';
import 'package:rentshare_app/models/wallet_model.dart';
import '../services/wallet_service.dart';

class WalletViewModel extends ChangeNotifier {
  WalletModel? _walletData; 
  bool _isLoading = false;
  String _errorMessage = "";

  WalletModel? get walletData => _walletData;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<void> fetchWallet() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await WalletService.getWallet();
    _walletData = WalletModel.fromJson(response['data']);
      _errorMessage = "";
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  Future<bool> depositMoney(double amount) async {
    _isLoading = true;
    notifyListeners();

    try {
      await WalletService.deposit(amount);
      await Future.delayed(const Duration(seconds: 3));
      await fetchWallet(); 
      _isLoading = false;
      notifyListeners();
      return true; 
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false; 
    }
  }
}