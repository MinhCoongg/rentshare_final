import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentshare_app/models/conversation.dart';
import 'package:rentshare_app/viewmodels/auth_viewmodel.dart';
import 'package:rentshare_app/viewmodels/chat_viewmodel.dart';
import 'package:rentshare_app/views/chat/chat.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  int  myId = 0;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      setState(() {
        myId = authProvider.id ?? 0;
      });
      Provider.of<ChatViewModel>(context, listen: false).fetchConversations();
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text("Tin nhắn", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: Consumer<ChatViewModel>(
        builder: (context, vm, child) {
          if (vm.isLoading) return Center(child: CircularProgressIndicator());
          if (vm.conversations.isEmpty) return Center(child: Text("Chưa có cuộc trò chuyện nào"));
          return ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            itemCount: vm.conversations.length,
            itemBuilder: (context, index) {
              final chat = vm.conversations[index];
              return _buildChatCard(chat);
            },
          );
        },
      ),
    );
  }

  Widget _buildChatCard(Conversation chat) {
    String peerName = (chat.user1Id == myId) ? chat.user2Name : chat.user1Name;
    return Card(
      elevation: 2,
      margin: EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(
            builder: (context) => ChatScreen(
              conversationId: chat.id,
              myUserId: myId,
              shopName: peerName
            )
          ));
        },
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  'http://192.168.1.17:3001${chat.productImage}', 
                  width: 60, height: 60, fit: BoxFit.cover
                ),
              ),
              SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(peerName, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text(
                      chat.lastMessage, 
                      style: TextStyle(color: Colors.redAccent, fontSize: 14),
                      maxLines: 1, 
                      overflow: TextOverflow.ellipsis,
                      
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Về: ${chat.productName}", 
                      style: TextStyle(color: Colors.blueAccent, fontSize: 12, fontWeight: FontWeight.w500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}