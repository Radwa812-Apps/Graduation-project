/*import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/constants.dart';


import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  final String message;
  final String time;
  final bool isMe;
  final String senderName;
  final bool isImage;
  final String? imageUrl;

  const MessageBubble({
    Key? key,
    required this.message,
    required this.time,
    required this.isMe,
    required this.senderName,
    this.isImage = false,
    this.imageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        crossAxisAlignment: 
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!isMe)
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 2),
              child: Text(
                senderName,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            decoration: BoxDecoration(
              color: isMe ? kPrimaryColor1 : Colors.grey[200], // WhatsApp-like colors
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(isMe ? 12 : 0),
                topRight: Radius.circular(isMe ? 0 : 12),
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isImage && imageUrl != null)
                  _buildImageContent()
                else
                  _buildTextContent(),
              ],
            ),
          ),
        ],
      ),
    );
  }

 Widget _buildTextContent() {
  return IntrinsicWidth(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isMe)
          Text(
            senderName,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        Text(
          message,
          style: TextStyle(
            color: isMe ? Colors.white : Colors.black,
            fontSize: 16,
          ),
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              _formatTimestamp(time),
              style: TextStyle(
                color: isMe ? Colors.white70 : Colors.grey[600],
                fontSize: 11,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

String _formatTimestamp(dynamic timestamp) {
  if (timestamp == null) return 'Just now';
  if (timestamp is Timestamp) {
    final date = timestamp.toDate();
    return DateFormat('HH:mm').format(date);
  }
  return timestamp.toString();
}

  Widget _buildImageContent() {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            imageUrl!,
            width: double.infinity,
            height: 200,
            fit: BoxFit.cover,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Align(
            alignment: Alignment.bottomRight,
            child: Text(
              time,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 11,
              ),
            ),
          ),
        ),
      ],
    );
  }
}*/
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:intl/intl.dart';
import '../../../core/constants.dart';

class MessageBubble extends StatefulWidget {
  final String message;
  final String time;
  final bool isMe;
  final String senderName;
  final bool isImage;
  final String? imageUrl;
  final bool isVoice; // Added for voice messages
  final String? voiceUrl; // Added for voice messages

  const MessageBubble({
    Key? key,
    required this.message,
    required this.time,
    required this.isMe,
    required this.senderName,
    this.isImage = false,
    this.imageUrl,
    this.isVoice = false,
    this.voiceUrl,
  }) : super(key: key);

  @override
  _MessageBubbleState createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _playPauseVoiceMessage() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
      setState(() => _isPlaying = false);
    } else {
      if (widget.voiceUrl != null) {
        await _audioPlayer.play(UrlSource(widget.voiceUrl!));
        setState(() => _isPlaying = true);
        _audioPlayer.onPlayerComplete.listen((event) {
          setState(() => _isPlaying = false);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        crossAxisAlignment:
            widget.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!widget.isMe)
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 2),
              child: Text(
                widget.senderName,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            decoration: BoxDecoration(
              color: widget.isMe ? kPrimaryColor1 : Colors.grey[200],
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(widget.isMe ? 12 : 0),
                topRight: Radius.circular(widget.isMe ? 0 : 12),
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.isVoice && widget.voiceUrl != null)
                  _buildVoiceContent()
                else if (widget.isImage && widget.imageUrl != null)
                  _buildImageContent()
                else
                  _buildTextContent(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextContent() {
    return IntrinsicWidth(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.message,
            style: TextStyle(
              color: widget.isMe ? Colors.white : Colors.black,
              fontSize: 16,
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                _formatTimestamp(widget.time),
                style: TextStyle(
                  color: widget.isMe ? Colors.white70 : Colors.grey[600],
                  fontSize: 11,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageContent() {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            widget.imageUrl!,
            width: double.infinity,
            height: 200,
            fit: BoxFit.cover,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Align(
            alignment: Alignment.bottomRight,
            child: Text(
              widget.time,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 11,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVoiceContent() {
    return IntrinsicWidth(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(
                  _isPlaying ? Icons.pause : Icons.play_arrow,
                  color: widget.isMe ? Colors.white : Colors.black,
                ),
                onPressed: _playPauseVoiceMessage,
              ),
              const SizedBox(width: 8),
              Text(
                'Voice Message',
                style: TextStyle(
                  color: widget.isMe ? Colors.white : Colors.black,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                _formatTimestamp(widget.time),
                style: TextStyle(
                  color: widget.isMe ? Colors.white70 : Colors.grey[600],
                  fontSize: 11,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(String time) {
    // Since the time is already a string in HH:mm format, just return it
    return time;
  }
}