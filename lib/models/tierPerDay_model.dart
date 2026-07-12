class TierPricingModel {
  final int minDays;
  final double pricePerDay;

  TierPricingModel({
    required this.minDays,
    required this.pricePerDay,
  });

  factory TierPricingModel.fromJson(Map<String, dynamic> json) {
    return TierPricingModel(
      minDays: json['minDays'] ?? 0,
      pricePerDay: double.parse(json['pricePerDay'].toString()),
    );
  }
}