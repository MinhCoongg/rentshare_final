import 'dart:io';

import 'package:flutter/material.dart';
import 'package:rentshare_app/models/conversation.dart';
import '../services/chat_service.dart';

class ChatViewModel extends ChangeNotifier {
  final ChatService _chatService = ChatService();
  List<dynamic> messages = [];
  List<Conversation> conversations = [];
  bool isLoading = true;

  void initChat(int conversationId, int myUserId) {
    _chatService.connect(conversationId);

    _chatService.socket.off('chat_history');
    _chatService.socket.off('receive_message');

    // Lắng nghe lịch sử
    _chatService.socket.on('chat_history', (data) {
      if (data is List) {
        messages = List<dynamic>.from(data);
        isLoading = false;
        notifyListeners();
      }
    });

    // Lắng nghe tin nhắn mới
    _chatService.socket.on('receive_message', (data) {
      if (data != null) {
        messages.add(data);
        notifyListeners();
      }
    });
}

  void sendMessage(int conversationId, int senderId, String content, {String messageType = 'text'}) {
    _chatService.sendMessage(conversationId, senderId, content, messageType: messageType);
  }

  Future<void> uploadAndSendImage(File imageFile, int conversationId, int myUserId) async {
    try {
      String? imageUrl = await _chatService.uploadImage(imageFile);
      
      if (imageUrl != null) {
        String fullImageUrl = imageUrl;
        sendMessage(conversationId, myUserId, fullImageUrl, messageType: 'image');
      } else {
        debugPrint("Lỗi upload ảnh!");
      }
    } catch (e) {
      debugPrint("Lỗi gửi ảnh: $e");
    }
  }
  
  @override
  void dispose() {
    _chatService.socket.off('chat_history');
    _chatService.socket.off('receive_message');
    _chatService.disconnect();
    super.dispose();
  }

  Future<void> fetchConversations() async {
    isLoading = true;
    notifyListeners();
    conversations = await _chatService.getConversations();
    debugPrint('Dữ liệu: $conversations');
    isLoading = false;
    notifyListeners();
  }
}