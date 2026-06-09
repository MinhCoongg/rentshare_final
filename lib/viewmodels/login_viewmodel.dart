import 'package:flutter/material.dart';
import 'package:rentshare_app/utils/sharetoken_utils.dart';
import 'package:shared_preferences/shared_preferences.dart'; 
import 'package:rentshare_app/models/login_model.dart';
import 'package:rentshare_app/models/user_model.dart';
import 'package:rentshare_app/services/login_services.dart';

class LoginViewModel extends ChangeNotifier {
  final LoginModel _loginData = LoginModel();
  bool _isLoading = false;
  UserModel? _currentUser; 
  String _token = '';

  LoginModel get loginData => _loginData;
  bool get isLoading => _isLoading;
  UserModel? get currentUser => _currentUser;
  String get token => _token;
  bool _isPasswordObscured = true;
  bool get isPasswordObscured => _isPasswordObscured;

  void togglePasswordVisibility() {
    _isPasswordObscured = !_isPasswordObscured;
    notifyListeners(); 
  }
  void updateEmail(String value) {
    _loginData.email = value;
    notifyListeners();
  }

  void updatePassword(String value) {
    _loginData.password = value;
    notifyListeners();
  }

  Future<String?> loginWithApi() async {
    _isLoading = true;
    notifyListeners();
    final result = await LoginServices.login(_loginData.email, _loginData.password);
    _isLoading = false;
    notifyListeners();
    
    if (result['succeeded'] == true) {
      _currentUser = result['user'] as UserModel;
      _token = result['token'] ?? '';
      await SharedPrefsUtils.saveToken(_token);
    
      

      return null; 
    } else {
      return result['message']; 
    }
  }

  Future<bool> checkLoggedInStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final savedToken = prefs.getString('user_token');
    if (savedToken != null && savedToken.isNotEmpty) {
      _token = savedToken;
      return true; 
    }
    return false;
  }
}