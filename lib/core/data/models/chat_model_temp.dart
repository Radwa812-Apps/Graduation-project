import 'package:flutter/material.dart';

class ChatModelTemp with ChangeNotifier {
  final List<Map<String, String>> _chats = [];

  List<Map<String, String>> get chats => _chats;

  void addMessage(String recipient, String message, String time) {
    final chat = _chats.firstWhere(
      (chat) => chat['recipient'] == recipient,
      orElse: () => {'recipient': recipient, 'message': message, 'time': time},
    );

    if (chat['recipient'] == recipient) {
      chat['message'] = message;
      chat['time'] = time;
    } else {
      _chats.add(chat);
    }

    notifyListeners();
  }
}