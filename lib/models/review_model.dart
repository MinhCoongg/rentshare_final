class ReviewModel {
  final int id;
  final int userId;
  final int productId;
  final double rating;
  final String comment;
  final DateTime createdAt;
  final String userName;
  final String? avatar;
  final List<String> images;

  ReviewModel({
    required this.id,
    required this.userId,
    required this.productId,
    required this.rating,
    required this.comment,
    required this.createdAt,
    required this.userName,
    this.avatar,
    required this.images,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json["id"],
      userId: json["userId"],
      productId: json["productId"],
      rating: double.parse(json["rating"].toString()),
      comment: json["comment"] ?? "",
      createdAt: DateTime.parse(json["createdAt"]),
      userName: json["userName"] ?? "",
      avatar: json["avatar"],
      images: json["images"] == null
          ? []
          : List<String>.from(json["images"]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "userId": userId,
      "productId": productId,
      "rating": rating,
      "comment": comment,
      "createdAt": createdAt.toIso8601String(),
      "userName": userName,
      "avatar": avatar,
      "images": images,
    };
  }
}