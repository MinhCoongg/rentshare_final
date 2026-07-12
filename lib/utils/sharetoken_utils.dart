import 'dart:convert';
import 'package:rentshare_app/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsUtils {
  static const String _tokenKey = "user_token";
  static const String _userKey = "user_data";

  // --- Token ---
  static Future<String> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey) ?? '';
  }

  static Future<bool> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setString(_tokenKey, token);
  }

  static Future<bool> saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  static Future<UserModel?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_userKey);
    if (jsonString != null) {
      return UserModel.fromJson(jsonDecode(jsonString));
    }
    return null;
  }


  static Future<bool> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.clear(); 
  }
}