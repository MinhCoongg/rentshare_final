class UserModel {
  final int? id; // Thêm id để đồng bộ dữ liệu từ DB trả về khi đăng nhập
  final String name;
  final String email;
  final String phoneNumber;
  final String?
  password; // Cho phép null vì khi đăng nhập thành công thường ẩn mật khẩu
  final String? avatar;

  UserModel({
    this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    this.password,
    this.avatar,
  });

  // 1. CHUYỂN JSON THÀNH ĐỐI TƯỢNG USERMODEL (Giải quyết lỗi của bạn)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber:
          json['phoneNumber'] ??
          json['phone_number'] ??
          '', // Handle cả 2 cách viết key nếu có
      avatar: json['avatar'],
    );
  }

  // 2. CHUYỂN ĐỐI TƯỢNG USERMODEL THÀNH JSON (Dùng cho Đăng ký)
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      if (password != null) 'password': password,
      if (avatar != null) 'avatar': avatar,
    };
  }
}
