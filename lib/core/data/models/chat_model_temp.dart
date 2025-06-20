import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:near_me_new_version/core/services/chat_services.dart';
import 'package:provider/provider.dart';

class ChatModelTemp with ChangeNotifier {
  List<Map<String, dynamic>> _recentChats = [];

  List<Map<String, dynamic>> get recentChats => _recentChats;

  void updateRecentChats(List<Map<String, dynamic>> chats) {
    _recentChats = chats;
    notifyListeners();
  }

  void addMessage(BuildContext context, String recipientId, String message, String time, String recipientName, String? recipientImage) {
    final chatService = Provider.of<ChatService>(context, listen: false);
    final chat = _recentChats.firstWhere(
      (chat) => chat['recipientId'] == recipientId,
      orElse: () => {
        'recipientId': recipientId,
        'recipientName': recipientName,
        'recipientImage': recipientImage,
        'lastMessage': message,
        'time': time,
        'timestamp': Timestamp.now(),
      },
    );

    if (chat['recipientId'] == recipientId) {
      chat['lastMessage'] = message;
      chat['time'] = time;
      chat['timestamp'] = Timestamp.now();
    } else {
      _recentChats.add(chat);
    }

    _recentChats.sort((a, b) => (b['timestamp'] as Timestamp).compareTo(a['timestamp'] as Timestamp));
    notifyListeners();
  }
}