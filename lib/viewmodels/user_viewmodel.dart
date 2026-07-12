import 'package:flutter/foundation.dart';
import 'package:rentshare_app/models/user_model.dart';
import 'package:rentshare_app/services/user_service.dart';

class UserViewModel extends ChangeNotifier {
  final UserService _service = UserService();
  
  List<UserModel> users = [];
  Map<String, dynamic> stats = {};
  bool isLoading = false; 
  
  String _currentStatus = ''; 
  String _currentSearch = '';

  String get selectedStatus => _currentStatus;

  Future<void> loadUsers({String? status, String? search}) async {
    if (status != null) _currentStatus = status;
    if (search != null) _currentSearch = search;
    
    isLoading = true;
    notifyListeners();
    try {
      final response = await _service.fetchUsers(
        status: _currentStatus == 'Tất cả' ? '' : _currentStatus, 
        search: _currentSearch
      );

      users = (response['data'] as List).map((json) => UserModel.fromJson(json)).toList();
      stats = response['stats'];
    } catch (e) {
      debugPrint("Lỗi tải người dùng: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> filterByStatus(String status) async {
    await loadUsers(status: status);
  }


  Future<void> searchUsers(String query) async {
    await loadUsers(search: query);
  }


  Future<void> toggleUserStatus(UserModel user) async {
    String newStatus = (user.status == 'Blocked') ? 'Active' : 'Blocked';
    try {
      await _service.updateStatus(user.id, newStatus);
      await loadUsers(); 
    } catch (e) {
      debugPrint("Lỗi cập nhật: $e");
    }
  }
}