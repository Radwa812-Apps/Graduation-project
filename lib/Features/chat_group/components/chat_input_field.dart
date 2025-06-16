import 'package:flutter/material.dart';
import '../../../core/constants.dart';

class ChatInputField extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback onEmojiPressed;
  final VoidCallback onMediaPressed;
  final bool isRecording;
  final bool isSending;

  const ChatInputField({
    Key? key,
    required this.controller,
    required this.onSend,
    required this.onEmojiPressed,
    required this.onMediaPressed,
    this.isSending = false,
    this.isRecording = false,
  }) : super(key: key);

  @override
  _ChatInputFieldState createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField> {
  bool _showSendButton = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleTextChange);
  }

  void _handleTextChange() {
    setState(() => _showSendButton = widget.controller.text.isNotEmpty);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.emoji_emotions_outlined, color: Colors.black54),
                    onPressed: widget.onEmojiPressed,
                  ),
                  Expanded(
                    child: TextField(
                      controller: widget.controller,
                      decoration: const InputDecoration(
                        hintText: "Message",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.attach_file, color: Colors.black54),
                    onPressed: widget.onMediaPressed,
                  ),
                  IconButton(
                    icon: Icon(Icons.camera_alt_outlined, color: Colors.black54),
                    onPressed: widget.onMediaPressed,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _showSendButton && !widget.isSending ? widget.onSend : null,
            child: CircleAvatar(
              radius: 21,
              backgroundColor: _showSendButton ? kPrimaryColor1 : Colors.grey[400],
              child: widget.isSending
                  ? const CircularProgressIndicator(
                      color: background,
                      strokeWidth: 2,
                    )
                  : const Icon(
                      Icons.send_outlined,
                      color: background,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleTextChange);
    super.dispose();
  }
}