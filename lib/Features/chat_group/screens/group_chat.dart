import 'package:flutter/material.dart';
import 'package:near_me_new_version/Features/Notifications/Components/date_label.dart' show DateLabel;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants.dart';
import '../components/chat_input_field.dart';
import '../components/header_chat.dart';
import '../components/message_bubble.dart';

class GroupChat extends StatefulWidget {
  const GroupChat({super.key});
  static String groupChatKey = '/GroupChat';
  @override
  _GroupChatState createState() => _GroupChatState();
}

class _GroupChatState extends State<GroupChat> {
  final TextEditingController _messageController = TextEditingController();
  List<Map<String, String>> _messages = [];

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  void _loadMessages() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? savedMessages = prefs.getStringList('group_chat_messages');
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
    prefs.setStringList('group_chat_messages', messagesToSave);
  }

  void _sendMessage() {
    if (_messageController.text.isNotEmpty) {
      setState(() {
        _messages.add({
          "message": _messageController.text,
          "time": "${DateTime.now().hour}:${DateTime.now().minute}",
        });
        _messageController.clear();
        _saveMessages();
      });
    }
  }

  void _clearChat() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('group_chat_messages');
    setState(() {
      _messages.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final String groupName =
        ModalRoute.of(context)!.settings.arguments as String;
    return Scaffold(
      backgroundColor: background,
      body: Column(
        children: [
          HeaderChat(
            onClearChatPressed: _clearChat,
            title: groupName,
            backArrow: const Icon(
              Icons.arrow_back_ios,
              color: kPrimaryColor1,
              size: 25,
            ),
            showCircleAvatar: true,
            image: "assets/images/group.jpg",
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
