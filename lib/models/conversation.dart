class Conversation {
  final int id;
  final int productId;
  final int user1Id;
  final int user2Id;
  final String productName;
  final String productImage;
  final String user1Name;
  final String user2Name;
  final String lastMessage;

  Conversation({
    required this.id,
    required this.productId,
    required this.user1Id,
    required this.user2Id,
    required this.productName,
    required this.productImage,
    required this.user1Name,
    required this.user2Name,
    required this.lastMessage
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'] ?? 0,
      productId: json['product_id'] ?? 0,
      user1Id: json['user1_id'] ?? 0,
      user2Id: json['user2_id'] ?? 0,
      productName: json['productName'] ?? 'Sản phẩm không tên',
      productImage: json['productImage'] ?? '',
      user1Name: json['user1Name'] ?? 'Người dùng 1',
      user2Name: json['user2Name'] ?? 'Người dùng 2',
      lastMessage: json['lastMessage'] ?? 'Chưa có tin nhắn',
    );
  }
}