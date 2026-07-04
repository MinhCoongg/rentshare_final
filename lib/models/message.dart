class Message {
  final int id;
  final int conversationId;
  final int senderId;
  final String content;
  final String messageType;
  final DateTime createdAt;
  final String? senderAvatar; 

  Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.content,
    required this.messageType,
    required this.createdAt,
    this.senderAvatar,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] ?? 0,
      conversationId: json['conversation_id'] ?? 0,
      senderId: json['sender_id'] ?? 0,
      content: json['content'] ?? "",
      messageType: json['messageType'] ?? 'text',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toString()),
      senderAvatar: json['sender_avatar'],
    );
  }
}