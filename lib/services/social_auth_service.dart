import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SocialAuthService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  // ============================================
  // ĐĂNG NHẬP BẰNG GOOGLE
  // ============================================
  static Future<Map<String, dynamic>?> signInWithGoogle() async {
    try {
      // Đăng nhập Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      // Lấy thông tin user
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Lấy chi tiết user
      final response = await http.get(
        Uri.parse('https://www.googleapis.com/oauth2/v3/userinfo'),
        headers: {'Authorization': 'Bearer ${googleAuth.accessToken}'},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to get user info');
      }

      final userData = jsonDecode(response.body);

      return {
        'id': userData['sub'],
        'email': userData['email'],
        'name': userData['name'],
        'avatar': userData['picture'],
        'provider': 'google',
        'accessToken': googleAuth.accessToken,
      };
    } catch (error) {
      print('Google Sign-In Error: $error');
      return null;
    }
  }

  // ============================================
  // ĐĂNG NHẬP BẰNG FACEBOOK
  // ============================================
  static Future<Map<String, dynamic>?> signInWithFacebook() async {
    try {
      // Đăng nhập Facebook
      final LoginResult result = await FacebookAuth.instance.login(
        permissions: ['public_profile', 'email'],
      );

      if (result.status != LoginStatus.success) {
        return null;
      }

      // Lấy thông tin user
      final userData = await FacebookAuth.instance.getUserData(
        fields: "id,name,email,picture.width(200)",
      );

      if (userData == null) return null;

      final pictureUrl = userData['picture']?['data']?['url'] ?? '';
      final accessToken = result.accessToken?.tokenString ?? '';

      return {
        'id': userData['id'],
        'email': userData['email'],
        'name': userData['name'],
        'avatar': pictureUrl,
        'provider': 'facebook',
        'accessToken': accessToken,
      };
    } catch (error) {
      print('Facebook Sign-In Error: $error');
      return null;
    }
  }

  // ============================================
  // GỬI THÔNG TIN LÊN BACKEND
  // ============================================
  static Future<Map<String, dynamic>> loginWithSocial({
    required String email,
    required String name,
    required String provider,
    required String providerId,
    String? avatar,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:3001/api/auth/social-login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'name': name,
          'provider': provider,
          'providerId': providerId,
          'avatar': avatar,
        }),
      );

      final data = jsonDecode(response.body);
      return data;
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }

  // ============================================
  // ĐĂNG XUẤT TẤT CẢ
  // ============================================
  static Future<void> signOutAll() async {
    await _googleSignIn.signOut();
    await FacebookAuth.instance.logOut();
  }
}
