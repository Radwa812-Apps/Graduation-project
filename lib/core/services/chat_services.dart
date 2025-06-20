import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:near_me_new_version/core/Encryption/encrypt_message.dart';
import 'dart:io';
import 'package:near_me_new_version/core/services/cloudinary_service.dart';
import 'package:intl/intl.dart';

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
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance {
    _cloudinaryService = cloudinary ?? CloudinaryService(auth: _auth, encryptionKey: encryptionKey);
    _encryption = MessageEncryption(encryptionKey);
  }

  String? get currentUserId => _auth.currentUser?.uid;

  String getChatId(String recipientId) {
    final userId = currentUserId;
    if (userId == null) throw Exception('User not authenticated');
    final ids = [userId, recipientId]..sort();
    return '${ids[0]}_${ids[1]}';
  }

  Future<String> uploadVoiceMessage(String chatId, String voicePath) async {
    try {
      final url = await _cloudinaryService.uploadVoiceMessage(
        File(voicePath),
        folder: 'private_chats/$chatId/voice',
      );
      print('Uploaded voice URL: $url');
      return url;
    } catch (e) {
      print('Voice message upload failed: $e');
      rethrow;
    }
  }

  Future<String> uploadVideo(String chatId, String videoPath) async {
    try {
      final url = await _cloudinaryService.uploadVideo(
        File(videoPath),
        folder: 'private_chats/$chatId/videos',
      );
      print('Uploaded video URL: $url');
      return url;
    } catch (e) {
      print('Video upload failed: $e');
      rethrow;
    }
  }

  Future<String> uploadImage(String chatId, String imagePath) async {
    try {
      final url = await _cloudinaryService.uploadImage(
        File(imagePath),
        folder: 'private_chats/$chatId/images',
      );
      print('Uploaded image URL: $url');
      return url;
    } catch (e) {
      print('Image upload failed: $e');
      rethrow;
    }
  }

  Future<void> sendPrivateMessage({
    required String recipientId,
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

      final recipientDoc = await _firestore.collection('users').doc(recipientId).get();
      final recipientName = recipientDoc.data()?['firstName'] != null
          ? "${recipientDoc.data()!['firstName']} ${recipientDoc.data()!['lastName'] ?? ''}".trim()
          : recipientDoc.data()?['email']?.split('@').first ?? 'User';
      final recipientImage = recipientDoc.data()?['image'];

      final encryptedText = text.isNotEmpty ? _encryption.encryptText(text) : '';

      final chatId = getChatId(recipientId);
      await _firestore
          .collection('private_chats')
          .doc(chatId)
          .collection('messages')
          .add({
        'text': encryptedText,
        'senderId': user.uid,
        'senderName': senderName,
        'imageUrl': imageUrl,
        'videoUrl': videoUrl,
        'voiceUrl': voiceUrl,
        'timestamp': FieldValue.serverTimestamp(),
        'createdAt': DateTime.now().toIso8601String(),
        'messageType': voiceUrl != null
            ? 'voice'
            : imageUrl != null
                ? 'image'
                : videoUrl != null
                    ? 'video'
                    : 'text'
      });

      await _firestore.collection('users').doc(user.uid).collection('recent_chats').doc(recipientId).set({
        'recipientId': recipientId,
        'recipientName': recipientName,
        'recipientImage': recipientImage,
        'lastMessage': text.isNotEmpty ? text : (voiceUrl != null ? 'Voice message' : imageUrl != null ? 'Image' : 'Video'),
        'time': DateFormat('HH:mm').format(DateTime.now()),
        'timestamp': FieldValue.serverTimestamp(),
      });

      await _firestore.collection('users').doc(recipientId).collection('recent_chats').doc(user.uid).set({
        'recipientId': user.uid,
        'recipientName': senderName,
        'recipientImage': userDoc.data()?['image'],
        'lastMessage': text.isNotEmpty ? text : (voiceUrl != null ? 'Voice message' : imageUrl != null ? 'Image' : 'Video'),
        'time': DateFormat('HH:mm').format(DateTime.now()),
        'timestamp': FieldValue.serverTimestamp(),
      });

      print('Private message sent successfully to $recipientId');
    } catch (e) {
      print('Failed to send private message: $e');
      rethrow;
    }
  }

  Stream<List<Map<String, dynamic>>> getPrivateMessages(String recipientId) {
    final chatId = getChatId(recipientId);
    return _firestore
        .collection('private_chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .distinct()
        .handleError((error) => print("Stream error: $error"))
        .map((snapshot) {
          print("Received ${snapshot.docs.length} private messages");
          return snapshot.docs.map((doc) {
            final data = doc.data();
            final decryptedText = data['text'] != null && data['text'].isNotEmpty
                ? _encryption.decryptText(data['text'])
                : '';
            return {
              'id': doc.id,
              'text': decryptedText,
              'senderId': data['senderId'] ?? '',
              'senderName': data['senderName'] ?? 'Unknown',
              'timestamp': data['timestamp'] ?? Timestamp.now(),
              'imageUrl': data['imageUrl'],
              'videoUrl': data['videoUrl'],
              'voiceUrl': data['voiceUrl'],
            };
          }).toList();
        });
  }

  Stream<List<Map<String, dynamic>>> streamRecentChats() {
    final userId = currentUserId;
    if (userId == null) return Stream.value([]);
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('recent_chats')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => doc.data()).toList();
        });
  }

  Future<List<Map<String, dynamic>>> getRecentChats() async {
    final userId = currentUserId;
    if (userId == null) return [];
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('recent_chats')
        .orderBy('timestamp', descending: true)
        .get();
    return snapshot.docs.map((doc) => doc.data()).toList();
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

      await _firestore
          .collection('groups')
          .doc(groupId)
          .collection('messages')
          .add({
        'text': encryptedText,
        'senderId': user.uid,
        'senderName': senderName,
        'imageUrl': imageUrl,
        'videoUrl': videoUrl,
        'voiceUrl': voiceUrl,
        'timestamp': FieldValue.serverTimestamp(),
        'createdAt': DateTime.now().toIso8601String(),
        'messageType': voiceUrl != null
            ? 'voice'
            : imageUrl != null
                ? 'image'
                : videoUrl != null
                    ? 'video'
                    : 'text'
      });
      print('Message sent successfully to group $groupId');
    } catch (e) {
      print('Failed to send message: $e');
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
            return {
              'id': doc.id,
              'text': decryptedText,
              'senderId': data['senderId'] ?? '',
              'senderName': data['senderName'] ?? 'Unknown',
              'timestamp': data['timestamp'] ?? Timestamp.now(),
              'imageUrl': data['imageUrl'],
              'videoUrl': data['videoUrl'],
              'voiceUrl': data['voiceUrl'],
            };
          }).toList();
        });
  }
}