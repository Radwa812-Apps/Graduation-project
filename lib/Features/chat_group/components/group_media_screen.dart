import 'package:flutter/material.dart';
import 'package:near_me_new_version/Features/chat_group/components/full_screen_image_viewer.dart';
import 'package:near_me_new_version/Features/chat_group/components/video_player_widget.dart';
import 'package:near_me_new_version/core/constants.dart';

class GroupMediaScreen extends StatelessWidget {
  final List<Map<String, dynamic>> messages;
  final String groupName;

  const GroupMediaScreen({
    Key? key,
    required this.messages,
    required this.groupName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mediaMessages = messages.where((msg) =>
        (msg['imageUrl'] != null && msg['imageUrl'].isNotEmpty) ||
        (msg['videoUrl'] != null && msg['videoUrl'].isNotEmpty) ||
        (msg['voiceUrl'] != null && msg['voiceUrl'].isNotEmpty)).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('$groupName'),
        backgroundColor: kPrimaryColor1.withOpacity(.5),
      ),
      body: mediaMessages.isEmpty
          ? const Center(child: Text('No media found'))
          : GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemCount: mediaMessages.length,
              itemBuilder: (context, index) {
                final message = mediaMessages[index];
                if (message['imageUrl'] != null && message['imageUrl'].isNotEmpty) {
                  return GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FullScreenImageViewer(imageUrl: message['imageUrl']),
                      ),
                    ),
                    child: Image.network(
                      message['imageUrl'],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
                    ),
                  );
                } else if (message['videoUrl'] != null && message['videoUrl'].isNotEmpty) {
                  return GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VideoPlayerWidget(url: message['videoUrl']),
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(color: Colors.black),
                        const Icon(Icons.play_circle_outline, color: Colors.white, size: 40),
                      ],
                    ),
                  );
                } else if (message['voiceUrl'] != null && message['voiceUrl'].isNotEmpty) {
                  return GestureDetector(
                    onTap: () {
                      // Optionally handle voice message playback
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Voice message: ${message['voiceUrl']}')),
                      );
                    },
                    child: Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.audiotrack, size: 40),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
    );
  }
}