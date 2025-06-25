import 'dart:developer';
import 'dart:typed_data';
import 'package:flutter/material.dart';

class RoundImageWidget extends StatelessWidget {
  final Uint8List? imageBytes;
  final String? assetImagePath;
  final double? width;
  final double? height;

  const RoundImageWidget({
    super.key,
    this.imageBytes,
    this.assetImagePath,
    this.width = 60,
    this.height = 60,
  });

  @override
  Widget build(BuildContext context) {
    ImageProvider imageProvider;

    try {
      if (imageBytes != null) {
        imageProvider = MemoryImage(imageBytes!);
        log("image byte not null..${imageBytes!.length}");
      } else {
        imageProvider = AssetImage(assetImagePath ?? 'assets/images/group.jpg');
      }
    } catch (e) {
      print('❌ Error loading image: $e');
      imageProvider = const AssetImage('assets/images/group.jpg');
    }

    return ClipOval(
      child: Image(
        image: imageProvider,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          log('❌ Image render failed: $error');
          return Image.asset(
            'assets/images/default_group.png',
            width: width,
            height: height,
            fit: BoxFit.cover,
          );
        },
      ),
    );
  }
}
