class Adminproduct {
  final int id;
  final String title;
  final String datePosted;
  final String status;
  final String ownerName;
  final String ownerEmail;
  final String categoryName;
  final String imageUrl;
  final String pricePerDay;

  Adminproduct({
    required this.id,
    required this.title,
    required this.datePosted,
    required this.status,
    required this.ownerName,
    required this.ownerEmail,
    required this.categoryName,
    required this.imageUrl,
    required this.pricePerDay,
  });

  factory Adminproduct.fromJson(Map<String, dynamic> json) {
    return Adminproduct(
      id: json['id'],
      title: json['title'] ?? '',
      datePosted: json['datePosted'] ?? '',
      status: json['status'] ?? '',
      ownerName: json['ownerName'] ?? '',
      ownerEmail: json['ownerEmail'] ?? '',
      categoryName: json['categoryName'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      pricePerDay: json['pricePerDay'] ?? '0',
    );
  }
}