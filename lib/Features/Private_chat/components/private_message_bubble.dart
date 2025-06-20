import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:near_me_new_version/core/constants.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:near_me_new_version/Features/chat_group/components/full_screen_image_viewer.dart';
import 'package:near_me_new_version/Features/chat_group/components/video_player_widget.dart';

class PrivateMessageBubble extends StatefulWidget {
  final String message;
  final dynamic timestamp;
  final bool isMe;
  final String? imageUrl;
  final String? videoUrl;
  final String? voiceUrl;

  const PrivateMessageBubble({
    Key? key,
    required this.message,
    required this.timestamp,
    required this.isMe,
    this.imageUrl,
    this.videoUrl,
    this.voiceUrl,
  }) : super(key: key);

  @override
  State<PrivateMessageBubble> createState() => _PrivateMessageBubbleState();
}

class _PrivateMessageBubbleState extends State<PrivateMessageBubble> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _setupAudioPlayer();
  }

  void _setupAudioPlayer() {
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() => _isPlaying = state == PlayerState.playing);
      }
    });
    _audioPlayer.onDurationChanged.listen((duration) {
      if (mounted) {
        setState(() => _duration = duration);
      }
    });
    _audioPlayer.onPositionChanged.listen((position) {
      if (mounted) {
        setState(() => _position = position);
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  String _formatTimestamp() {
    if (widget.timestamp == null) return 'Just now';
    if (widget.timestamp is Timestamp) {
      final date = widget.timestamp.toDate();
      return DateFormat('HH:mm').format(date);
    }
    return widget.timestamp.toString();
  }

  Widget _buildTimestamp() {
    return Text(
      _formatTimestamp(),
      style: TextStyle(
        color: widget.isMe ? Colors.white70 : Colors.grey[600],
        fontSize: 11,
      ),
    );
  }

  Widget _buildTextContent() {
    if (widget.message.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.message,
          style: TextStyle(
            color: widget.isMe ? Colors.white : Colors.black,
          ),
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: _buildTimestamp(),
        ),
      ],
    );
  }

  void _showFullImage(BuildContext context, String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenImageViewer(imageUrl: imageUrl),
      ),
    );
  }

  Widget _buildImageContent() {
    if (widget.imageUrl == null || widget.imageUrl!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => _showFullImage(context, widget.imageUrl!),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              widget.imageUrl!,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const SizedBox(
                  height: 200,
                  child: Center(child: CircularProgressIndicator()),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                print('Image load error: $error');
                return Container(
                  height: 200,
                  color: Colors.grey[300],
                  child: const Center(child: Icon(Icons.error)),
                );
              },
            ),
          ),
        ),
        _buildTimestamp(),
      ],
    );
  }

  Widget _buildVideoContent() {
    if (widget.videoUrl == null || widget.videoUrl!.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 200,
          child: VideoPlayerWidget(url: widget.videoUrl!),
        ),
        _buildTimestamp(),
      ],
    );
  }

  Widget _buildVoiceContent() {
    if (widget.voiceUrl == null || widget.voiceUrl!.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              icon: Icon(
                _isPlaying ? Icons.pause : Icons.play_arrow,
                color: widget.isMe ? Colors.white : Colors.blue,
              ),
              onPressed: () async {
                try {
                  if (_isPlaying) {
                    await _audioPlayer.pause();
                  } else {
                    await _audioPlayer.play(UrlSource(widget.voiceUrl!));
                  }
                  if (mounted) setState(() {});
                } catch (e) {
                  print('Voice playback error: $e');
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to play voice message: $e')),
                    );
                  }
                }
              },
            ),
            Expanded(
              child: Slider(
                min: 0,
                max: _duration.inSeconds.toDouble(),
                value: _position.inSeconds.toDouble().clamp(0, _duration.inSeconds.toDouble()),
                onChanged: (seconds) async {
                  try {
                    await _audioPlayer.seek(Duration(seconds: seconds.toInt()));
                    if (mounted) setState(() {});
                  } catch (e) {
                    print('Voice seek error: $e');
                  }
                },
                activeColor: widget.isMe ? Colors.white70 : kPrimaryColor1,
                inactiveColor: widget.isMe ? Colors.white30 : Colors.grey,
              ),
            ),
            Text(
              '${_position.inMinutes}:${(_position.inSeconds % 60).toString().padLeft(2, '0')}',
              style: TextStyle(
                color: widget.isMe ? Colors.white70 : Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
        _buildTimestamp(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.message.isEmpty &&
        (widget.imageUrl == null || widget.imageUrl!.isEmpty) &&
        (widget.videoUrl == null || widget.videoUrl!.isEmpty) &&
        (widget.voiceUrl == null || widget.voiceUrl!.isEmpty)) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Align(
        alignment: widget.isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: widget.isMe ? kPrimaryColor1 : Colors.grey[200],
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(widget.isMe ? 12 : 0),
                topRight: Radius.circular(widget.isMe ? 0 : 12),
                bottomLeft: const Radius.circular(12),
                bottomRight: const Radius.circular(12),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty)
                  _buildImageContent()
                else if (widget.videoUrl != null && widget.videoUrl!.isNotEmpty)
                  _buildVideoContent()
                else if (widget.voiceUrl != null && widget.voiceUrl!.isNotEmpty)
                  _buildVoiceContent()
                else
                  _buildTextContent(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}