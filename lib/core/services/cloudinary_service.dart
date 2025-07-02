import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:near_me_new_version/core/Encryption/encrypt_message.dart';

class CloudinaryService {
  static const String _cloudName = 'da7ora77f';
  static const String _uploadPreset = 'chat_media';
  
  final CloudinaryPublic _cloudinary;
  final FirebaseAuth _auth;
  final MessageEncryption _encryption;

  CloudinaryService({
    required FirebaseAuth auth,
    required String encryptionKey,
  }) : 
    _auth = auth,
    _encryption = MessageEncryption(encryptionKey),
    _cloudinary = CloudinaryPublic(_cloudName, _uploadPreset, cache: false);

  Future<String> uploadImage(File imageFile, {String? folder}) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');
      final response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imageFile.path,
          folder: folder ?? 'user_uploads/${user.uid}',
          resourceType: CloudinaryResourceType.Image,
        ),
      );
      return response.secureUrl;
    } catch (e) {
      print('Cloudinary upload error: $e');
      rethrow;
    }
  }

  Future<String> uploadVideo(File videoFile, {String? folder}) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');
      final response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          videoFile.path,
          folder: folder ?? 'user_uploads/${user.uid}/videos',
          resourceType: CloudinaryResourceType.Video,
        ),
      );
      return response.secureUrl;
    } catch (e) {
      print('Cloudinary video upload error: $e');
      rethrow;
    }
  }

  Future<String> uploadVoiceMessage(File audioFile, {String? folder}) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');
      final response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          audioFile.path,
          folder: folder ?? 'user_uploads/${user.uid}/voice',
          resourceType: CloudinaryResourceType.Video,
        ),
      );
      return response.secureUrl;
    } catch (e) {
      print('Cloudinary voice upload error: $e');
      rethrow;
    }
  }

  Future<void> deleteFile(String publicId) async {
    try {
      print('Deletion should be handled via Cloud Function for security');
    } catch (e) {
      print('Error deleting file: $e');
      rethrow;
    }
  }
}