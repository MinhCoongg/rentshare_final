class AddressModel {
  final int? id; 
  final String receiverName;
  final String receiverPhone;
  final String fullAddress;
  final bool isDefault;

  AddressModel({
    this.id, 
    required this.receiverName,
    required this.receiverPhone,
    required this.fullAddress,
    this.isDefault = false,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'] as int?, 
      receiverName: (json['receiverName'] ?? "") as String,
      receiverPhone: (json['receiverPhone'] ?? "") as String,
      fullAddress: (json['fullAddress'] ?? "") as String,
      isDefault: json['isDefault'] == 1 || json['isDefault'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) "id": id, 
      "receiverName": receiverName,
      "receiverPhone": receiverPhone,
      "fullAddress": fullAddress,
      "isDefault": isDefault ? 1 : 0,
    };
  }
}