import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rentshare_app/constant/constant_url.dart';
import 'package:rentshare_app/models/conversation.dart';
import 'package:rentshare_app/utils/sharetoken_utils.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatService {
  late IO.Socket socket;
  bool _isSocketInitialized = false;

  void connect(int conversationId) {
    if (_isSocketInitialized && socket.connected) {
       socket.emit('join_conversation', conversationId);
       socket.emit('get_history', conversationId);
       return;
    }

    socket = IO.io('http://192.168.1.17:3001', IO.OptionBuilder()
        .setTransports(['websocket']) 
        .disableAutoConnect()
        .build());

    socket.connect(); 

    socket.onConnect((_) {
      debugPrint('ChatService: Kết nối server thành công!');
      _isSocketInitialized = true; // Đánh dấu đã khởi tạo thành công
      socket.emit('join_conversation', conversationId);
      socket.emit('get_history', conversationId);
    });

    socket.onConnectError((err) => debugPrint('Lỗi kết nối Socket: $err'));
  }

  void sendMessage(int conversationId, int senderId, String content, {String messageType = 'text'}) {
    socket.emit('send_message', {
      'conversationId': conversationId,
      'senderId': senderId,
      'content': content,
      'messageType': messageType,
    });
  }

  void disconnect() {
    socket.disconnect();
  }

  static Future<int> getOrCreateConversation(int productId, int ownerId) async {
    final String token = await SharedPrefsUtils.getToken();
    final response = await http.post(
      Uri.parse('${ConstantURL.baseUrl}/chat/get-or-create'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        },
      body: jsonEncode({
        'productId': productId,
        'ownerId': ownerId,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['conversationId'];
    } else {
      throw Exception('Server từ chối: ${response.body}');
    }
  }

  Future<String?> uploadImage(File imageFile) async {
    try {
      var request = http.MultipartRequest(
        'POST', 
        Uri.parse('${ConstantURL.baseUrl}/upload-image')
      );

      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path)
      );
      String token = await SharedPrefsUtils.getToken();
      request.headers['Authorization'] = 'Bearer $token';

      // 4. Gửi lên Server
      var response = await request.send();

      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var jsonResponse = jsonDecode(responseData);
        return jsonResponse['imageUrl'];
      } else {
        debugPrint("Lỗi upload status: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      debugPrint("Lỗi khi gọi hàm uploadImage: $e");
      return null;
    }
  }

  Future<List<Conversation>> getConversations() async {
    try {
      final String token = await SharedPrefsUtils.getToken();
      final response = await http.get(
        Uri.parse('${ConstantURL.baseUrl}/my-conversations'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body)['data'];
        return data.map((json) => Conversation.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint("Lỗi Service: $e"); 
      return [];
    }
  }
}