import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants.dart';
import '../../Notifications/Components/date_label.dart';
import '../../chat_group/components/chat_input_field.dart';
import '../../chat_group/components/header_chat.dart';
import '../../chat_group/components/message_bubble.dart';

class PrivateChatScreen extends StatefulWidget {
  final String recipient;
  const PrivateChatScreen({super.key, required this.recipient});

  static String privateChatScreenKey = '/PrivateChatScreen';

  @override
  State<PrivateChatScreen> createState() => _PrivateChatScreenState();
}

class _PrivateChatScreenState extends State<PrivateChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  List<Map<String, String>> _messages = [];

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  void _loadMessages() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? savedMessages =
        prefs.getStringList('messages_${widget.recipient}');
    if (savedMessages != null) {
      setState(() {
        _messages = savedMessages.map((message) {
          List<String> parts = message.split('|');
          return {"message": parts[0], "time": parts[1]};
        }).toList();
      });
    }
  }

  void _saveMessages() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> messagesToSave = _messages.map((message) {
      return "${message["message"]}|${message["time"]}";
    }).toList();
    prefs.setStringList('messages_${widget.recipient}', messagesToSave);
  }

  void _sendMessage() {
    if (_messageController.text.isNotEmpty) {
      setState(() {
        String messageText = _messageController.text;
        String time = "${DateTime.now().hour}:${DateTime.now().minute}";

        _messages.add({
          "message": messageText,
          "time": time,
        });

        _messageController.clear();
        _saveMessages();

        _saveRecentChat(widget.recipient, messageText, time);
      });
    }
  }

  void _saveRecentChat(
      String recipient, String lastMessage, String time) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? recentChats = prefs.getStringList('recent_chats') ?? [];

    recentChats.removeWhere((chat) => chat.startsWith('$recipient|'));

    recentChats.insert(0, '$recipient|$lastMessage|$time');

    prefs.setStringList('recent_chats', recentChats);
  }

  void _clearChat() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('messages');
    setState(() {
      _messages.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final String name = ModalRoute.of(context)!.settings.arguments as String;
    return Scaffold(
      backgroundColor: background,
      body: Column(
        children: [
          HeaderChat(
            onClearChatPressed: _clearChat,
            title: name,
            backArrow: const Icon(
              Icons.arrow_back_ios,
              color: kPrimaryColor1,
              size: 25,
            ),
            showCircleAvatar: true,
            image: "assets/images/user.jpg",
          ),
          const DateLabel(dateText: 'Yesterday'),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 10),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return MessageBubble(
                  message: message["message"]!,
                  time: message["time"]!,
                );
              },
            ),
          ),
          ChatInputField(
            controller: _messageController,
            onSend: _sendMessage,
          ),
        ],
      ),
    );
  }
}
