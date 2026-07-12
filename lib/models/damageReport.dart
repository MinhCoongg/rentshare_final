class DamageReport {
  final int id;
  final int rentalId;
  final String complainBy;
  final String title;
  final String reason;
  final String evidence;
  final double compensationAmount;
  final String? adminNote;
  final String status;
  final DateTime createdAt;
  final DateTime? resolvedAt;
  final String ownerNote;

  DamageReport({
    required this.id,
    required this.rentalId,
    required this.complainBy,
    required this.title,
    required this.reason,
    required this.evidence,
    required this.compensationAmount,
    this.adminNote,
    required this.status,
    required this.createdAt,
    this.resolvedAt,
    required this.ownerNote,
  });

  factory DamageReport.fromJson(Map<String, dynamic> json) {
    return DamageReport(
      id: json['id'],
      rentalId: json['rentalId'],
      complainBy: json['complainBy'] ?? '',
      title: json['title'] ?? '',
      reason: json['reason'] ?? '',
      evidence: json['evidence'] ?? '',
      compensationAmount: double.tryParse(json['compensationAmount'].toString()) ?? 0.0,
      adminNote: json['adminNote'],
      status: json['status'] ?? 'Pending',
      createdAt: DateTime.parse(json['createdAt']),
      resolvedAt: json['resolvedAt'] != null ? DateTime.parse(json['resolvedAt']) : null,
      ownerNote: json['ownerNote'] ?? '',
    );
  }
}