import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentshare_app/utils/sharetoken_utils.dart'; 
import 'package:rentshare_app/models/login_model.dart';
import 'package:rentshare_app/models/user_model.dart';
import 'package:rentshare_app/services/login_services.dart';
import 'package:rentshare_app/viewmodels/auth_viewmodel.dart';

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

  Future<String?> loginWithApi(BuildContext context) async {
    _isLoading = true;
    notifyListeners();
    
    final result = await LoginServices.login(_loginData.email, _loginData.password);
    
    _isLoading = false;
    notifyListeners();

    if (result['succeeded'] == true) {
      final String token = result['token'] ?? '';
      final UserModel user = result['user'] as UserModel; 
      if (context.mounted) {
        await context.read<AuthProvider>().saveAuth(token, user);
      }

      _currentUser = user;
      _token = token;
      
      return null; 
    } else {
      return result['message']; 
    }
  }

  Future<bool> checkLoggedInStatus() async {
    final savedToken = await SharedPrefsUtils.getToken();
    if (savedToken.isNotEmpty) {
      _token = savedToken;
      final savedUser = await SharedPrefsUtils.getUser();
      if (savedUser != null) {
        _currentUser = savedUser;
        notifyListeners(); 
        return true;
      }
    }
    return false;
  }

  Future<void> logout() async {
    await SharedPrefsUtils.clearAll(); 
    _currentUser = null;
    _token = '';
    notifyListeners();
  }
}