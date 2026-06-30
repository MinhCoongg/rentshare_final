import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:rentshare_app/models/login_model.dart';
import 'package:rentshare_app/models/user_model.dart';
import 'package:rentshare_app/services/login_services.dart';
import 'package:rentshare_app/services/profile_service.dart';

class AuthProvider extends ChangeNotifier {

  final LoginModel _loginData = LoginModel();

  UserModel? _user;
  String? _token;

  bool _isLoading = false;
  bool _isPasswordObscured = true;

  LoginModel get loginData => _loginData;

  UserModel? get user => _user;

  String? get token => _token;

  bool get isAuthenticated => _token != null && _user != null;

  bool get isLoading => _isLoading;

  bool get isPasswordObscured => _isPasswordObscured;


  void updateEmail(String value) {
    _loginData.email = value;
    notifyListeners();
  }

  void updatePassword(String value) {
    _loginData.password = value;
    notifyListeners();
  }

  void togglePasswordVisibility() {
    _isPasswordObscured = !_isPasswordObscured;
    notifyListeners();
  }


  Future<String?> login() async {
    _isLoading = true;
    notifyListeners();

    final result = await LoginServices.login(
      _loginData.email,
      _loginData.password,
    );

    _isLoading = false;

    if (result["succeeded"] == true) {
      final token = result["token"] as String;
      final user = result["user"] as UserModel;

      await saveAuth(token, user);

      notifyListeners();
      return null;
    }

    notifyListeners();
    return result["message"];
  }


  Future<void> loadAuthData() async {
    final prefs = await SharedPreferences.getInstance();

    _token = prefs.getString("user_token");

    final userJson = prefs.getString("user_data");

    if (userJson != null) {
      _user = UserModel.fromJson(jsonDecode(userJson));
    }

    notifyListeners();
  }

  Future<void> saveAuth(
      String token,
      UserModel userModel,
      ) async {

    final prefs = await SharedPreferences.getInstance();

    _token = token;
    _user = userModel;

    await prefs.setString(
      "user_token",
      token,
    );

    await prefs.setString(
      "user_data",
      jsonEncode(userModel.toJson()),
    );

    notifyListeners();
  }

  Future<void> logout() async {

    final prefs = await SharedPreferences.getInstance();

    await prefs.clear();

    _user = null;
    _token = null;

    notifyListeners();
  }


  Future<void> updateUserLocally(UserModel newUser) async {

    _user = newUser;

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      "user_data",
      jsonEncode(newUser.toJson()),
    );

    notifyListeners();
  }


  Future<void> uploadAvatar(File imageFile) async {

    try {

      String? avatar =
          await ProfileService.uploadAvatr(imageFile);

      if (avatar == null) return;

      _user = _user?.copyWith(
        avatar: avatar,
      );

      final prefs = await SharedPreferences.getInstance();

      await prefs.setString(
        "user_data",
        jsonEncode(_user!.toJson()),
      );

      notifyListeners();

    } catch (e) {

      debugPrint(e.toString());

      rethrow;
    }
  }

  Future<void> updateProfile(UserModel updatedUser) async {
    try {
      final newUser =
          await ProfileService.updateProfile(user: updatedUser);
      _user = newUser;

      final prefs = await SharedPreferences.getInstance();

      await prefs.setString(
        "user_data",
        jsonEncode(newUser.toJson()),
      );

      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> changePassword({
    required String oldPassword, 
    required String newPassword
  }) async {
    try {
      bool success = await ProfileService.changePassword(oldPassword, newPassword);
      if (success) {
        debugPrint("AuthProvider: Đổi mật khẩu thành công");
        return true;
      }
      debugPrint("AuthProvider: Đổi mật khẩu thất bại");
      return false;
    } catch (e) {
      debugPrint("Lỗi tại AuthProvider (changePassword): $e");
      rethrow; 
    }
  }
}