import 'dart:developer';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:near_me_new_version/core/services/group_services.dart';

class ProfileImageService {
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  GroupService _groupService = GroupService();
  // Download and decrypt group image
  Future<Uint8List?> getDecryptedUserImage(String userId) async {
    log("Fetching image for $userId");

    if (userId == null) {
      print('❌ User not authenticated');
      return null;
    }
    try {
      final doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .get();

      if (doc.exists) {
        final encryptedImage = doc.data()?['encryptedUserPicture'] as String?;
        final encryptionKey = doc.data()?['encryptionKey'] as String?;

        if (encryptedImage != null && encryptionKey != null) {
          return _groupService.decryptImage(encryptedImage, encryptionKey);
        }
      }
      return null;
    } catch (e) {
      print('❌ Get image error: $e');
      return null;
    }
  }

  Future<Uint8List?> pickAndCompressImage(BuildContext context) async {
    try {
      final XFile? pickedFile = await _showImageSourceSelection(context);
      if (pickedFile == null) return null;

      final imageBytes = await pickedFile.readAsBytes();
      return await _compressImage(imageBytes);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${e.toString()}"),
          duration: const Duration(seconds: 3),
        ),
      );
      return null;
    }
  }

  Future<XFile?> _showImageSourceSelection(BuildContext context) async {
    return await showModalBottomSheet<XFile?>(
      context: context,
      isScrollControlled: true,
      builder:
          (context) => SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildImageOption(
                    icon: Icons.photo_library_outlined,
                    title: "Choose image from gallery",
                    onTap: () async {
                      final file = await _picker.pickImage(
                        source: ImageSource.gallery,
                        imageQuality: 70,
                        maxWidth: 1200,
                        maxHeight: 1200,
                      );
                      Navigator.pop(context, file);
                    },
                  ),
                  const Divider(height: 1),
                  _buildImageOption(
                    icon: Icons.camera_alt_outlined,
                    title: "Take a new photo",
                    onTap: () async {
                      final file = await _picker.pickImage(
                        source: ImageSource.camera,
                        imageQuality: 70,
                        maxWidth: 1200,
                        maxHeight: 1200,
                      );
                      Navigator.pop(context, file);
                    },
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildImageOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue), 
      title: Text(title, style: const TextStyle(fontSize: 16)),
      onTap: onTap,
    );
  }

  Future<Uint8List> _compressImage(Uint8List imageBytes) async {
    try {
      final result = await FlutterImageCompress.compressWithList(
        imageBytes,
        minHeight: 800,
        minWidth: 800,
        quality: 70,
        format: CompressFormat.jpeg,
      );
      return result ?? imageBytes;
    } catch (e) {
      print('❌ Compression error: $e');
      return imageBytes;
    }
  }

  void showUploadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text("Uploading image..."),
              ],
            ),
          ),
    );
  }

  void showSuccessMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Photo updated successfully"),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
