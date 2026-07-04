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
  final String? address; 
  final String? phoneNumber;
  final String? status;  
  final int? isOwner;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.avatar,
    required this.wallet,
    this.address,     
    this.phoneNumber, 
    this.isOwner,
    this.status
  });

  bool get isBlocked => status == 'Blocked';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      avatar: json['avatar'] ?? '',
      wallet: json['wallet'] != null ? WalletModel.fromJson(json['wallet']) : WalletModel(balance: 0.0),
      address: json['address'], 
      phoneNumber: json['phoneNumber'],
      status: json['status'],
      isOwner: json['isOwner'],
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
      'address': address,       
      'phoneNumber': phoneNumber, 
      'status': status,      
      'isOwner': isOwner,
    };
  }

  UserModel copyWith({
    int? id,
    String? name,
    String? email,
    String? role,
    String? avatar,
    WalletModel? wallet,
    String? diaChi,
    String? phoneNumber,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      avatar: avatar ?? this.avatar,
      wallet: wallet ?? this.wallet,
      address: address ?? this.address,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      status: status ?? this.status,
      isOwner: isOwner ?? this.isOwner,
    );
  }
}