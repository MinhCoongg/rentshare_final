import 'package:flutter/material.dart';
import '../services/register_services.dart';

class RegisterViewModel extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<String?> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    final result = await RegisterServices.register(
      name: name,
      email: email,
      phone: phone,
      password: password,
    );

    _isLoading = false;
    notifyListeners();

    if (result['succeeded'] == true) {
      return null; // Không có lỗi -> Đăng ký thành công
    } else {
      return result['message']; // Trả về nội dung lỗi hiển thị lên SnackBar
    }
  }
}
