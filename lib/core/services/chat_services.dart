
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:near_me_new_version/core/Encryption/encrypt_message.dart';
import 'dart:io';
import 'package:near_me_new_version/core/services/cloudinary_service.dart';

class ChatService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  late final CloudinaryService _cloudinaryService;
  late final MessageEncryption _encryption;

  ChatService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    CloudinaryService? cloudinary,
    required String encryptionKey,
  }) : 
    _auth = auth ?? FirebaseAuth.instance,
    _firestore = firestore ?? FirebaseFirestore.instance {
    _cloudinaryService = cloudinary ?? CloudinaryService(auth: _auth, encryptionKey: encryptionKey);
    _encryption = MessageEncryption(encryptionKey);
  }

  String? get currentUserId => _auth.currentUser?.uid;

  Future<String> uploadVoiceMessage(String groupId, String voicePath) async {
    try {
      final url = await _cloudinaryService.uploadVoiceMessage(
        File(voicePath),
        folder: 'group_chats/$groupId/voice',
      );
      print('Uploaded voice URL: $url');
      return url;
    } catch (e) {
      print('Voice message upload failed: $e');
      rethrow;
    }
  }

  Future<String> uploadVideo(String groupId, String videoPath) async {
    try {
      final url = await _cloudinaryService.uploadVideo(
        File(videoPath),
        folder: 'group_chats/$groupId/videos',
      );
      print('Uploaded video URL: $url');
      return url;
    } catch (e) {
      print('Video upload failed: $e');
      rethrow;
    }
  }

  Future<void> sendMessage({
    required String groupId,
    required String text,
    String? imageUrl,
    String? videoUrl,
    String? voiceUrl,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final firstName = userDoc.data()?['firstName'] ?? '';
      final lastName = userDoc.data()?['lastName'] ?? '';
      final senderName = (firstName + ' ' + lastName).trim().isNotEmpty
          ? (firstName + ' ' + lastName).trim()
          : userDoc.data()?['email']?.split('@').first ?? 'User';

      final encryptedText = text.isNotEmpty ? _encryption.encryptText(text) : '';
      // No encryption for image, video, or voice URLs
      print('Sending message - Encrypted Text: $encryptedText, Image URL: $imageUrl, Video URL: $videoUrl, Voice URL: $voiceUrl');

      await _firestore
          .collection('groups')
          .doc(groupId)
          .collection('messages')
          .add({
        'text': encryptedText,
        'senderId': user.uid,
        'senderName': senderName,
        'imageUrl': imageUrl, // Store plain URL for images
        'videoUrl': videoUrl, // Store plain URL for videos
        'voiceUrl': voiceUrl, // Store plain URL for voice
        'timestamp': FieldValue.serverTimestamp(),
        'createdAt': DateTime.now().toIso8601String(),
        'messageType': voiceUrl != null ? 'voice' : 
                      imageUrl != null ? 'image' :
                      videoUrl != null ? 'video' : 'text'
      });
      print('Message sent successfully to group $groupId');
    } catch (e) {
      print('Failed to send message: $e');
      rethrow;
    }
  }

  Future<String> uploadImage(String groupId, String imagePath) async {
    try {
      final url = await _cloudinaryService.uploadImage(
        File(imagePath),
        folder: 'group_chats/$groupId/images',
      );
      print('Uploaded image URL: $url');
      return url;
    } catch (e) {
      print('Image upload failed: $e');
      rethrow;
    }
  }

  Stream<List<Map<String, dynamic>>> getGroupMessages(String groupId) {
    return _firestore
        .collection('groups')
        .doc(groupId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .distinct()
        .handleError((error) => print("Stream error: $error"))
        .map((snapshot) {
          print("Received ${snapshot.docs.length} messages");
          return snapshot.docs.map((doc) {
            final data = doc.data();
            final decryptedText = data['text'] != null && data['text'].isNotEmpty
                ? _encryption.decryptText(data['text'])
                : '';

            print("Message data - Decrypted Text: $decryptedText, Image URL: ${data['imageUrl']}, Video URL: ${data['videoUrl']}, Voice URL: ${data['voiceUrl']}");
            return {
              'id': doc.id,
              'text': decryptedText,
              'senderId': data['senderId'] ?? '',
              'senderName': data['senderName'] ?? 'Unknown',
              'timestamp': data['timestamp'] ?? Timestamp.now(),
              'imageUrl': data['imageUrl'], // Use plain URL for images
              'videoUrl': data['videoUrl'], // Use plain URL for videos
              'voiceUrl': data['voiceUrl'], // Use plain URL for voice
            };
          }).toList();
        });
  }
}