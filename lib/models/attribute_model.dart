class AttributeModel {
  final int id;
  final String attributeName;

  AttributeModel({required this.id, required this.attributeName});

  factory AttributeModel.fromJson(Map<String, dynamic> json) {
    return AttributeModel(
      id: json['id'],
      attributeName: json['attributeName'],
    );
  }
}