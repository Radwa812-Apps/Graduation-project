
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Map<String, String> _userNameCache = {};

  String? get currentUserId => _auth.currentUser?.uid;


  Future<void> sendMessage({
  required String groupId,
  required String text,
  String? imageUrl,
}) async {
  try {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // Get fresh user data
    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    final senderName = userDoc.data()?['displayName'] ?? 
                      userDoc.data()?['email']?.split('@').first ?? 
                      'User';

    // Create message with mandatory fields
    await _firestore
        .collection('groups')
        .doc(groupId)
        .collection('messages')
        .add({
      'text': text,
      'senderId': user.uid,
      'senderName': senderName,
      'imageUrl': imageUrl,
      'timestamp': FieldValue.serverTimestamp(), // Critical change
      'createdAt': DateTime.now().toIso8601String() // Backup field
    });
    
    print('Message sent successfully to group $groupId');
  } catch (e) {
    print('Failed to send message: $e');
    rethrow;
  }
}
  Future<String> uploadImage(String groupId, String imagePath) async {
    try {
      final fileName = 'img_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child('group_chats/$groupId/images/$fileName');
      await ref.putFile(File(imagePath));
      return await ref.getDownloadURL();
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
      .handleError((error) => print("Stream error: $error"))
      .map((snapshot) {
        print("Received ${snapshot.docs.length} messages");
        return snapshot.docs.map((doc) {
          final data = doc.data();
          print("Message data: ${data.toString()}");
          return {
            'id': doc.id,
            'text': data['text'] ?? '',
            'senderId': data['senderId'] ?? '',
            'senderName': data['senderName'] ?? 'Unknown',
            'timestamp': data['timestamp'] ?? Timestamp.now(),
            'imageUrl': data['imageUrl'],
          };
        }).toList();
      });
}
  // ========== CACHING METHODS ==========
  Future<void> _cacheGroupMembers(String groupId) async {
    try {
      final groupDoc = await _firestore.collection('groups').doc(groupId).get();
      final members = List<String>.from(groupDoc.data()?['members'] ?? []);
      await Future.wait(members.map(_cacheUserName));
    } catch (e) {
      print('Error caching group members: $e');
    }
  }

  Future<void> _cacheUserName(String userId) async {
    if (_userNameCache.containsKey(userId)) return;
    
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      _userNameCache[userId] = userDoc.data()?['name'] ?? 'User ${userId.substring(0, 4)}';
    } catch (e) {
      _userNameCache[userId] = 'User ${userId.substring(0, 4)}';
    }
  }

  // ========== UTILITIES ==========
  String _formatTime(DateTime date) {
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }
}