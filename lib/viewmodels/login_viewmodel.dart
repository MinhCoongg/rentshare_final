import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentshare_app/utils/sharetoken_utils.dart'; 
import 'package:rentshare_app/models/login_model.dart';
import 'package:rentshare_app/models/user_model.dart';
import 'package:rentshare_app/services/login_services.dart';
import 'package:rentshare_app/viewmodels/auth_viewmodel.dart';
import 'package:rentshare_app/viewmodels/wishlist_viewmodel.dart';


class LoginViewModel extends ChangeNotifier {
  final LoginModel _loginData = LoginModel();
  bool _isLoading = false;
  String? _errorMessage;
  UserModel? _currentUser; 
  String _token = '';
  
  String get userRole => _currentUser?.role ?? '';
  LoginModel get loginData => _loginData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
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
      final int id = user.id;
      if (context.mounted) {
        await context.read<AuthProvider>().saveAuth(token, user, id);
        //await Provider.of<WishlistProvider>(context, listen: false).fetchWishlist();
        if (user.role == 'User') {
          await Provider.of<WishlistProvider>(context, listen: false).fetchWishlist();
        }
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

  Future<void> logout(BuildContext context) async {
    await SharedPrefsUtils.clearAll(); 
    Provider.of<WishlistProvider>(context, listen: false).clearWishlist();
    _currentUser = null;
    _token = '';
    notifyListeners();
  }

  Future<bool> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      bool success = await LoginServices.registerUser(
        name: name,
        email: email,
        phoneNumber: phone,
        password: password,
      );
      return success;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst("Exception: ", "");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}