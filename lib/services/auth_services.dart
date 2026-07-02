// lib/services/auth_services.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user_model.dart';

class AuthService {
  static const String _tokenKey = 'token';
  static const String _userKey = 'user_data';
  static const String _isLoggedInKey = 'is_logged_in';

  // ============================================
  // LƯU TOKEN
  // ============================================
  static Future<void> saveToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      await prefs.setBool(_isLoggedInKey, true);
      print('✅ Token saved');
    } catch (e) {
      print('❌ Error saving token: $e');
    }
  }

  // ============================================
  // LẤY TOKEN
  // ============================================
  static Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey);
    } catch (e) {
      print('❌ Error getting token: $e');
      return null;
    }
  }

  // ============================================
  // LƯU USER
  // ============================================
  static Future<void> saveUser(UserModel user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = jsonEncode(user.toJson());
      await prefs.setString(_userKey, userJson);
      await prefs.setBool(_isLoggedInKey, true);
      print('✅ User saved');
    } catch (e) {
      print('❌ Error saving user: $e');
    }
  }

  // ============================================
  // LẤY USER
  // ============================================
  static Future<UserModel?> getUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);

      if (userJson != null && userJson.isNotEmpty) {
        final Map<String, dynamic> userMap = jsonDecode(userJson);
        return UserModel.fromJson(userMap);
      }
      return null;
    } catch (e) {
      print('❌ Error getting user: $e');
      return null;
    }
  }

  // ============================================
  // LƯU TOÀN BỘ DỮ LIỆU AUTH
  // ============================================
  static Future<void> saveAuthData({
    required String token,
    required UserModel user,
  }) async {
    await saveToken(token);
    await saveUser(user);
    print('✅ Auth data saved');
  }

  // ============================================
  // KIỂM TRA ĐÃ ĐĂNG NHẬP CHƯA
  // ============================================
  static Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      final isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;
      return token != null && token.isNotEmpty && isLoggedIn;
    } catch (e) {
      return false;
    }
  }

  // ============================================
  // ĐĂNG XUẤT
  // ============================================
  static Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_userKey);
      await prefs.setBool(_isLoggedInKey, false);
      print('✅ Logout success');
    } catch (e) {
      print('❌ Error logging out: $e');
    }
  }

  // ============================================
  // CẬP NHẬT USER (SAU KHI CHỈNH SỬA)
  // ============================================
  static Future<void> updateUser(UserModel user) async {
    await saveUser(user);
    print('✅ User updated');
  }

  // ============================================
  // LẤY AUTH HEADERS (CHO API CALL)
  // ============================================
  static Future<Map<String, String>> getAuthHeaders() async {
    final token = await getToken();
    return {
      'Authorization': token != null ? 'Bearer $token' : '',
      'Content-Type': 'application/json',
    };
  }
}
