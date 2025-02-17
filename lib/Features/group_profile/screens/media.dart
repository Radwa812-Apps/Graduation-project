import 'package:flutter/material.dart';
import '../../../core/constants.dart';import 'package:video_player_control_panel/video_player_control_panel.dart';

class MediaScreen extends StatefulWidget {
  const MediaScreen({super.key});
  static String mediaScreenKey = '/MediaScreen';

  @override
  _MediaScreenState createState() => _MediaScreenState();
}

class _MediaScreenState extends State<MediaScreen> {
  final List<String> imageUrls = [];

  final List<String> videoUrls = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.3,
        backgroundColor: Colors.white,
        title: const Text(
          'Media Gallery',
          style: TextStyle(color: kFontColor),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: kFontColor,
            size: 28,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: _buildMediaGrid(),
    );
  }

  Widget _buildMediaGrid() {
    if (imageUrls.isEmpty && videoUrls.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/empty_media.png',
              width: 300,
              height: 300,
            ),
            const SizedBox(height: 16),
            const Text(
              'No media available',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    final List<String> mediaUrls = [...imageUrls, ...videoUrls];

    return GridView.builder(
      padding: const EdgeInsets.all(8.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
      ),
      itemCount: mediaUrls.length,
      itemBuilder: (context, index) {
        final mediaUrl = mediaUrls[index];
        final isVideo = videoUrls.contains(mediaUrl);

        return GestureDetector(
          onTap: () {
            if (isVideo) {
            } else {
              _showFullScreenImage(context, mediaUrl);
            }
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                isVideo ? 'assets/images/empty_media.png' : mediaUrl,
                fit: BoxFit.cover,
              ),
              if (isVideo)
                const Center(
                  child: Icon(
                    Icons.play_circle_filled,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _showFullScreenImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
            ),
          ),
        );
      },
    );
  }
}
