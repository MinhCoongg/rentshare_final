class ReviewModel {
  final String userName, userAvatar, comment, createdAt;
  final int rating;
  final List<String> images; 

  ReviewModel({
    required this.userName, 
    required this.userAvatar,
    required this.comment, 
    required this.createdAt, 
    required this.rating,
    this.images = const [],
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      userName: json['userName'] ?? 'Ẩn danh',
      userAvatar: json['userAvatar'] ?? '',
      comment: json['comment'] ?? '',
      createdAt: json['createdAt'] ?? '',
      rating: (json['rating'] ?? 5).toInt(),
      images: (json['images'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}