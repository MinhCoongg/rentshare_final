class WalletModel {
  final double balance;
  WalletModel({required this.balance});
  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      balance: double.tryParse(json['balance'].toString()) ?? 0.0,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'balance': balance.toString(),
    };
  }
}

class UserModel {
  final int id;
  final String name;
  final String email;
  final String role;
  final String avatar;
  final WalletModel wallet;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.avatar,
    required this.wallet,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      avatar: json['avatar'] ?? '',
      wallet: WalletModel.fromJson(json['wallet'] ?? {'balance': '0.0'}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'avatar': avatar,
      'wallet': wallet.toJson(), 
    };
  }
}