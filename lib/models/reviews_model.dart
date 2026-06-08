class ReviewModel {
  final String userName, userAvatar, comment, createdAt;
  final int rating;

  ReviewModel({
    required this.userName, required this.userAvatar,
    required this.comment, required this.createdAt, required this.rating,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      userName: json['userName'] ?? 'Ẩn danh',
      userAvatar: json['userAvatar'] ?? '',
      comment: json['comment'] ?? '',
      createdAt: json['createdAt'] ?? '',
      rating: json['rating'] ?? 5,
    );
  }
}