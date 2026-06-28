class PolicyModel {
  String type;
  double fineValue; 
  String unit;
  String content; 
  
  // Bây giờ chúng là các trường dữ liệu thực thụ từ DB
  double? lightDamage;  
  double? mediumDamage; 
  double? heavyDamage;  

  PolicyModel({
    required this.type,
    this.fineValue = 0.0,
    this.unit = 'VND',
    this.content = '',
    this.lightDamage,
    this.mediumDamage,
    this.heavyDamage,
  });

  factory PolicyModel.fromJson(Map<String, dynamic> json) {
    return PolicyModel(
      type: json['policyType'] ?? '', 
      fineValue: double.tryParse(json['fineValue']?.toString() ?? '0') ?? 0.0, 
      unit: json['unit'] ?? 'VND',
      lightDamage: json['light_damage'] != null ? double.tryParse(json['light_damage'].toString()) : null,
      mediumDamage: json['medium_damage'] != null ? double.tryParse(json['medium_damage'].toString()) : null,
      heavyDamage: json['heavy_damage'] != null ? double.tryParse(json['heavy_damage'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'type': type,
    'fineValue': fineValue,
    'unit': unit,
    'content': content,
    'light_damage': lightDamage, // Phải khớp với tên cột trong DB
    'medium_damage': mediumDamage,
    'heavy_damage': heavyDamage,
  };
}