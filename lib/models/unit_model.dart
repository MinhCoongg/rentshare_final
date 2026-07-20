class UnitModel {
  final int id;
  final String unitName;

  UnitModel({required this.id, required this.unitName});

  factory UnitModel.fromJson(Map<String, dynamic> json) {
    return UnitModel(
      id: json['id'] as int,
      unitName: json['unitName'] as String,
    );
  }
}