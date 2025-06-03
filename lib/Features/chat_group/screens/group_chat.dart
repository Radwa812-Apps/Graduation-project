
import 'dart:async' show StreamSubscription;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:near_me_new_version/core/services/chat_services.dart' show ChatService;
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';

import '../components/chat_input_field.dart';
import '../components/message_bubble.dart';

class GroupChat extends StatefulWidget {
  final String groupId;
  final String groupName;

  // Route configuration (modern approach)
  static const String routeName = '/group-chat';

  // Legacy support (if needed)
  static String get groupChatKey => routeName;

  // Route arguments helper
  static Map<String, String> createArguments(String groupId, String groupName) {
    return {
      'groupId': groupId,
      'groupName': groupName,
    };
  }

  const GroupChat({
    Key? key,
    required this.groupId,
    required this.groupName,
  }) : super(key: key);

  @override
  State<GroupChat> createState() => _GroupChatState();
}

class _GroupChatState extends State<GroupChat> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _imagePicker = ImagePicker();
  
  late ChatService _chatService;
  List<Map<String, dynamic>> _messages = [];
  bool _isSending = false;
  bool _showEmojiPicker = false;
  StreamSubscription? _messageSubscription;

  @override
  void initState() {
    super.initState();
    _chatService = Provider.of<ChatService>(context, listen: false);
    _setupMessageStream();
  }

  void _setupMessageStream() {
    _messageSubscription = _chatService.getGroupMessages(widget.groupId).listen(
      (messages) {
        if (mounted) {
          setState(() => _messages = messages);
          _scrollToBottom();
        }
      },
      onError: (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error loading messages: $error')),
          );
        }
      },
    );
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.isEmpty || _isSending) return;

    setState(() {
      _isSending = true;
      _showEmojiPicker = false;
    });

    try {
      await _chatService.sendMessage(
        groupId: widget.groupId,
        text: _messageController.text,
      );
      _messageController.clear();
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send message: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() => _isSending = true);
        final imageUrl = await _chatService.uploadImage(
          widget.groupId,
          pickedFile.path,
        );
        await _chatService.sendMessage(
          groupId: widget.groupId,
          text: '[Image]',
          imageUrl: imageUrl,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send image: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  void _toggleEmojiPicker() {
    setState(() {
      _showEmojiPicker = !_showEmojiPicker;
      FocusScope.of(context).unfocus();
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _showEmojiPicker = false),
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.groupName),
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                reverse: true,
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  final isMe = message['senderId'] == _chatService.currentUserId;
                  return MessageBubble(
                    message: message['text'] ?? '',
                    time: _formatTimestamp(message['timestamp']), // Handle null timestamp
                    isMe: isMe,
                    senderName: message['senderName'] ?? 'User',
                    isImage: message['imageUrl'] != null,
                    imageUrl: message['imageUrl'],
                );
                },
              ),
            ),
            ChatInputField(
              controller: _messageController,
              onSend: _sendMessage,
              isSending: _isSending,
              onEmojiPressed: _toggleEmojiPicker,
              onMediaPressed: _pickImage,
            ),
            if (_showEmojiPicker)
              SizedBox(
                height: 250,
                child: EmojiPicker(
                  onEmojiSelected: (category, emoji) {
                    _messageController.text += emoji.emoji;
                  },
                  config: const Config(
                    emojiViewConfig: EmojiViewConfig(
                      columns: 7,
                      emojiSizeMax: 32.0,
                      backgroundColor: Colors.white,
                    ),
                    categoryViewConfig: CategoryViewConfig(
                      backgroundColor: Colors.grey,
                      indicatorColor: Colors.blue,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
  String _formatTimestamp(dynamic timestamp) {
  if (timestamp == null) return 'Just now';
  if (timestamp is Timestamp) {
    final date = timestamp.toDate();
    return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
  return timestamp.toString(); // fallback
}
}