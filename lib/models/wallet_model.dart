class WalletModel {
  final int id;
  final int userId;
  final double balance;
  final double frozenAmount;
  final DateTime? updatedAt;

  WalletModel({
    required this.id,
    required this.userId,
    required this.balance,
    required this.frozenAmount,
    this.updatedAt,
  });


  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      id: json['id'] ?? 0,
      userId: json['userId'] ?? 0,
      balance: (json['balance'] as num).toDouble(),
      frozenAmount: (json['frozenAmount'] as num).toDouble(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : null,
    );
  }
}