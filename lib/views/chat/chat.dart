import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:rentshare_app/models/message.dart';
import 'package:rentshare_app/viewmodels/chat_viewmodel.dart';

class ChatScreen extends StatefulWidget {
  final int conversationId;
  final int myUserId;
  final String shopName;

  const ChatScreen({required this.conversationId, required this.myUserId, required this.shopName});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  late ChatViewModel _viewModel; 
  @override
  void initState() {
    super.initState();
    _viewModel = ChatViewModel();
    _viewModel.initChat(widget.conversationId, widget.myUserId);
  }

  @override
  void dispose() {
    _viewModel.dispose(); 
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          title: Text(widget.shopName, style: TextStyle(color: Colors.black)),
          iconTheme: IconThemeData(color: Colors.black),
        ),
        body: Consumer<ChatViewModel>(
          builder: (context, vm, child) {
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.all(10),
                    itemCount: vm.messages.length,
                    itemBuilder: (context, index) {
                      final Message msg = vm.messages[index];
                      bool isMe = msg.senderId == widget.myUserId;
                      String content = msg.content;
                      String type = msg.messageType;
                      if (type == 'image') {
                        return _buildImageBubble(content, isMe);
                      } else {
                        return _buildMessageBubble(content, isMe, msg.senderAvatar);
                      }
                    },
                  ),
                ),
                _buildMessageInput(context, vm),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMessageBubble(String msg, bool isMe, String? avatarUrl ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe)
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.transparent,
              backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty)
                  ? NetworkImage('http://192.168.1.17:3001$avatarUrl')
                  : null,
              child: (avatarUrl == null || avatarUrl.isEmpty)
                  ? Icon(Icons.person, color: Colors.grey)
                  : null,
            ),
          SizedBox(width: 8),
          Container(
            constraints: BoxConstraints(maxWidth: 250),
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isMe ? Color(0xFF1976D2) : Colors.grey[200],
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(msg, style: TextStyle(color: isMe ? Colors.white : Colors.black)),
          ),
        ],
      ),
    );
  }

  Widget _buildImageBubble(String imageUrl, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4),
        padding: EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isMe ? Color(0xFF1976D2) : Colors.grey[200],
          borderRadius: BorderRadius.circular(15),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network('http://192.168.1.17:3001$imageUrl', width: 200, height: 200, fit: BoxFit.cover),
        ),
      ),
    );
  }




  Widget _buildMessageInput(BuildContext context, ChatViewModel vm) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white, 
        boxShadow: [BoxShadow(blurRadius: 5, color: Colors.black12)]
      ),
      child: Row(
        children: [
          // 1. Nút thêm ảnh
          IconButton(
            icon: Icon(Icons.add_photo_alternate, color: Colors.blueAccent),
            onPressed: () async {
              final ImagePicker picker = ImagePicker();
              final XFile? image = await picker.pickImage(source: ImageSource.gallery);
              if (image != null) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Đang gửi ảnh...")));
                await vm.uploadAndSendImage(File(image.path), widget.conversationId, widget.myUserId);
              }
            },
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: "Nhập tin nhắn...", 
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 10),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send, color: Color(0xFF1976D2)),
            onPressed: () {
              if (_messageController.text.isNotEmpty) {
                // Gửi tin nhắn dạng Text
                vm.sendMessage(widget.conversationId, widget.myUserId, _messageController.text, messageType: 'text');
                _messageController.clear();
              }
            },
          )
        ],
      ),
    );
  }
}