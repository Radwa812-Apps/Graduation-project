
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:near_me_new_version/core/Encryption/encrypt_message.dart';
import 'dart:io';
import 'package:near_me_new_version/core/services/cloudinary_service.dart';
import 'package:intl/intl.dart';
import 'package:near_me_new_version/core/services/notification_service.dart';

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

  Future<void> markMessagesAsRead(String chatId, String recipientId) async {
    try {
      final userId = currentUserId;
      if (userId == null) return;

      final messages = await _firestore
          .collection('private_chats')
          .doc(chatId)
          .collection('messages')
          .where('senderId', isEqualTo: recipientId)
          .where('read', isEqualTo: false)
          .get();

      for (var doc in messages.docs) {
        await doc.reference.update({'read': true, 'readAt': FieldValue.serverTimestamp()});
      }
    } catch (e) {
      print('Error marking messages as read: $e');
    }
  }

  Future<void> markGroupMessagesAsRead(String groupId) async {
    try {
      final userId = currentUserId;
      if (userId == null) return;

      final messages = await _firestore
          .collection('groups')
          .doc(groupId)
          .collection('messages')
          .where('readBy', whereNotIn: [userId])
          .get();

      for (var doc in messages.docs) {
        await doc.reference.update({
          'readBy': FieldValue.arrayUnion([userId]),
          'readAt': FieldValue.serverTimestamp()
        });
      }
    } catch (e) {
      print('Error marking group messages as read: $e');
    }
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

  Stream<List<Map<String, dynamic>>> getPrivateMessages(String recipientId) {
    final chatId = getChatId(recipientId);
    final userId = currentUserId;

    return _firestore
        .collection('private_chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .distinct()
        .handleError((error) => print("Stream error: $error"))
        .map((snapshot) {
          return snapshot.docs.where((doc) {
            final data = doc.data();
            final deletedBy = List<String>.from(data['deletedBy'] ?? []);
            return userId == null || !deletedBy.contains(userId);
          }).map((doc) {
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

  Future<void> deleteChatForUser(String recipientId) async {
    try {
      final userId = currentUserId;
      if (userId == null) throw Exception('User not authenticated');

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('recent_chats')
          .doc(recipientId)
          .delete();

      final chatId = getChatId(recipientId);
      final messages = await _firestore
          .collection('private_chats')
          .doc(chatId)
          .collection('messages')
          .get();

      for (var doc in messages.docs) {
        await doc.reference.update({
          'deletedBy': FieldValue.arrayUnion([userId]),
        });
      }

      print('Chat and messages deleted for user $userId');
    } catch (e) {
      print('Failed to delete chat: $e');
      rethrow;
    }
  }

  Future<void> toggleMuteChat(String recipientId, bool mute) async {
    try {
      final userId = currentUserId;
      if (userId == null) throw Exception('User not authenticated');
      if (mute) {
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('muted_chats')
            .doc(recipientId)
            .set({'muted': true});
      } else {
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('muted_chats')
            .doc(recipientId)
            .delete();
      }
      print('Chat ${mute ? 'muted' : 'unmuted'} for user $userId');
    } catch (e) {
      print('Failed to toggle mute: $e');
      rethrow;
    }
  }

  Future<bool> isChatMuted(String recipientId) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        print('isChatMuted: No authenticated user found');
        return false;
      }
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('muted_chats')
          .doc(recipientId)
          .get();
      final isMuted = doc.exists && doc.data()?['muted'] == true;
      print('isChatMuted: Chat with $recipientId is ${isMuted ? 'muted' : 'not muted'} for user $userId');
      return isMuted;
    } catch (e) {
      print('Error checking mute status for chat with $recipientId: $e');
      return false;
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

    // Get sender info with proper name formatting
    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    final firstName = userDoc.data()?['firstName'] ?? '';
    final lastName = userDoc.data()?['lastName'] ?? '';
    final senderName = '${firstName.trim()} ${lastName.trim()}'.trim();
    final senderDisplayName = senderName.isNotEmpty 
        ? senderName
        : userDoc.data()?['email']?.split('@').first ?? 'User';
    final senderImage = userDoc.data()?['image'];

    // Get recipient info with proper name formatting
    final recipientDoc = await _firestore.collection('users').doc(recipientId).get();
    final recipientFirstName = recipientDoc.data()?['firstName'] ?? '';
    final recipientLastName = recipientDoc.data()?['lastName'] ?? '';
    final recipientName = '${recipientFirstName.trim()} ${recipientLastName.trim()}'.trim();
    final recipientDisplayName = recipientName.isNotEmpty
        ? recipientName
        : recipientDoc.data()?['email']?.split('@').first ?? 'User';
    final recipientImage = recipientDoc.data()?['image'];
    final recipientToken = recipientDoc.data()?['fcmToken'];

    // Check mute status
    final isMuted = await isChatMuted(recipientId);
    print('Sending message to $recipientId. Chat muted status: $isMuted');

    // Encrypt message text
    final encryptedText = text.isNotEmpty ? _encryption.encryptText(text) : '';

    // Create last message preview
    String lastMessagePreview;
    if (voiceUrl != null) {
      lastMessagePreview = '🎤 Voice message';
    } else if (imageUrl != null) {
      lastMessagePreview = '📷 Photo';
    } else if (videoUrl != null) {
      lastMessagePreview = '🎬 Video';
    } else {
      lastMessagePreview = text.isEmpty 
          ? '' 
          : text.length > 30 
              ? '${text.substring(0, 30)}...' 
              : text;
    }

    // Save message to Firestore
    final chatId = getChatId(recipientId);
    await _firestore
        .collection('private_chats')
        .doc(chatId)
        .collection('messages')
        .add({
      'text': encryptedText,
      'senderId': user.uid,
      'senderName': senderDisplayName,
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
                  : 'text',
      'read': false,
      'deletedBy': [],
    });

    // Update recent chats for both users with properly formatted names
    await _firestore.collection('users').doc(user.uid).collection('recent_chats').doc(recipientId).set({
      'recipientId': recipientId,
      'recipientName': recipientDisplayName,
      'recipientImage': recipientImage,
      'lastMessage': lastMessagePreview,
      'time': DateFormat('HH:mm').format(DateTime.now()),
      'timestamp': FieldValue.serverTimestamp(),
      'isMuted': isMuted,
    });

    await _firestore.collection('users').doc(recipientId).collection('recent_chats').doc(user.uid).set({
      'recipientId': user.uid,
      'recipientName': senderDisplayName,
      'recipientImage': senderImage,
      'lastMessage': lastMessagePreview,
      'time': DateFormat('HH:mm').format(DateTime.now()),
      'timestamp': FieldValue.serverTimestamp(),
      'isMuted': false, // Always false for recipient
    });

    // Send notification if not muted
    if (recipientToken != null && recipientToken.isNotEmpty && !isMuted) {
      final notificationTitle = 'New message from $senderDisplayName';
      String notificationBody;
      
      if (voiceUrl != null) {
        notificationBody = '🎤 Voice message';
      } else if (imageUrl != null) {
        notificationBody = '📷 Photo';
      } else if (videoUrl != null) {
        notificationBody = '🎬 Video';
      } else {
        notificationBody = text.isEmpty ? '' : text.length > 30 
            ? '${text.substring(0, 30)}...' 
            : text;
      }

      print('Sending notification to $recipientId');
      await NotificationService.sendChatNotification(
        recipientToken: recipientToken,
        title: notificationTitle,
        body: notificationBody,
        data: {
          'type': 'private_chat',
          'chatId': chatId,
          'senderId': user.uid,
          'senderName': senderDisplayName,
          'senderImage': senderImage,
          'recipientId': recipientId,
          'originallyMuted': isMuted.toString(),
        },
      );
    } else {
      print('Notification not sent to $recipientId. ' +
          'Muted: $isMuted, ' +
          'Token available: ${recipientToken != null && recipientToken.isNotEmpty}');
    }

    print('Private message sent successfully to $recipientId');
  } catch (e) {
    print('Failed to send private message: $e');
    rethrow;
  }
}

  Future<void> deleteMultipleMessages(List<String> messageIds, String recipientId) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('User not authenticated');

    final chatId = getChatId(recipientId);
    final batch = _firestore.batch();

    for (final messageId in messageIds) {
      final docRef = _firestore
          .collection('private_chats')
          .doc(chatId)
          .collection('messages')
          .doc(messageId);

      batch.update(docRef, {
        'deletedBy': FieldValue.arrayUnion([userId]),
      });
    }

    await batch.commit();
  }

  Future<void> deleteChatForEveryone(String recipientId) async {
    try {
      final userId = currentUserId;
      if (userId == null) throw Exception('User not authenticated');

      final chatId = getChatId(recipientId);

      await Future.wait([
        _firestore
            .collection('users')
            .doc(userId)
            .collection('recent_chats')
            .doc(recipientId)
            .delete(),
        _firestore
            .collection('users')
            .doc(recipientId)
            .collection('recent_chats')
            .doc(userId)
            .delete(),
      ]);

      final messages = await _firestore
          .collection('private_chats')
          .doc(chatId)
          .collection('messages')
          .get();

      final batch = _firestore.batch();
      for (var doc in messages.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      await _firestore
          .collection('private_chats')
          .doc(chatId)
          .delete();

      print('Chat deleted for both users: $userId and $recipientId');
    } catch (e) {
      print('Failed to delete chat for everyone: $e');
      rethrow;
    }
  }

  Future<void> deleteMessageForEveryone(String messageId, String recipientId) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('User not authenticated');

    final chatId = getChatId(recipientId);
    await _firestore
        .collection('private_chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .delete();
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
      .asyncMap((snapshot) async {
        final chats = <Map<String, dynamic>>[];
        
        for (var doc in snapshot.docs) {
          final chatData = doc.data();
          final recipientId = chatData['recipientId'];
          
          // Get fresh name data from users collection
          final userDoc = await _firestore.collection('users').doc(recipientId).get();
          final firstName = userDoc.data()?['firstName'] ?? '';
          final lastName = userDoc.data()?['lastName'] ?? '';
          final properName = '${firstName.trim()} ${lastName.trim()}'.trim();
          
          chats.add({
            ...chatData,
            'recipientName': properName.isNotEmpty ? properName : chatData['recipientName'],
            'isMuted': await isChatMuted(recipientId),
          });
        }
        
        return chats;
      });
}
Future<void> migrateChatNames() async {
  try {
    final userId = currentUserId;
    if (userId == null) {
      print('Migration aborted: No authenticated user');
      return;
    }

    print('Starting chat names migration...');
    final users = await _firestore.collection('users').get();
    int totalProcessed = 0;
    int totalUpdated = 0;

    for (final userDoc in users.docs) {
      final recentChats = await _firestore
          .collection('users')
          .doc(userDoc.id)
          .collection('recent_chats')
          .get();

      for (final chatDoc in recentChats.docs) {
        totalProcessed++;
        final chatData = chatDoc.data();
        final recipientId = chatData['recipientId'];

        try {
          final recipientDoc = await _firestore.collection('users').doc(recipientId).get();
          if (!recipientDoc.exists) continue;

          final firstName = recipientDoc.data()?['firstName'] ?? '';
          final lastName = recipientDoc.data()?['lastName'] ?? '';
          final properName = '${firstName.trim()} ${lastName.trim()}'.trim();

          if (properName.isNotEmpty && properName != chatData['recipientName']) {
            print('Updating name for ${chatData['recipientName']} to $properName');
            await chatDoc.reference.update({
              'recipientName': properName,
              'nameFormatted': true, // Add marker to indicate formatted name
            });
            totalUpdated++;
          }
        } catch (e) {
          print('Error processing chat with $recipientId: $e');
        }
      }
    }

    print('''
Migration completed:
- Total users processed: ${users.docs.length}
- Total chats processed: $totalProcessed
- Total names updated: $totalUpdated
''');
    
    // Mark migration as complete in Firestore
    await _firestore.collection('metadata').doc('migrations').set({
      'lastNameMigration': FieldValue.serverTimestamp(),
      'usersProcessed': users.docs.length,
      'chatsUpdated': totalUpdated,
    }, SetOptions(merge: true));

  } catch (e) {
    print('Fatal error during name migration: $e');
    rethrow;
  }
}

  Future<List<Map<String, dynamic>>> getRecentChats() async {
    final userId = currentUserId;
    if (userId == null) return [];
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('recent_chats')
        .orderBy('timestamp', descending: true)
        .limit(20)
        .get();
    final chats = snapshot.docs.map((doc) => doc.data()).toList();
    for (var chat in chats) {
      final isMuted = await isChatMuted(chat['recipientId']);
      chat['isMuted'] = isMuted;
    }
    return chats;
  }

  Future<bool> isGroupMuted(String groupId) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        print('isGroupMuted: No authenticated user found');
        return false;
      }
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('muted_groups')
          .doc(groupId)
          .get();
      final isMuted = doc.exists && doc.data()?['muted'] == true;
      print('isGroupMuted: Group $groupId is ${isMuted ? 'muted' : 'not muted'} for user $userId');
      return isMuted;
    } catch (e) {
      print('Error checking mute status for group $groupId: $e');
      return false;
    }
  }

  Future<void> toggleMuteGroup(String groupId, bool mute) async {
    try {
      final userId = currentUserId;
      if (userId == null) throw Exception('User not authenticated');
      if (mute) {
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('muted_groups')
            .doc(groupId)
            .set({'muted': true});
      } else {
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('muted_groups')
            .doc(groupId)
            .delete();
      }
      print('Group ${mute ? 'muted' : 'unmuted'} for user $userId');
    } catch (e) {
      print('Failed to toggle group mute: $e');
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
      final groupDoc = await _firestore.collection('groups').doc(groupId).get();
      final members = List<String>.from(groupDoc.data()?['members'] ?? []);

      members.removeWhere((memberId) => memberId == user.uid);

      if (members.isNotEmpty) {
        final usersSnapshot = await _firestore.collection('users')
            .where(FieldPath.documentId, whereIn: members)
            .get();

        for (final userDoc in usersSnapshot.docs) {
          final recipientId = userDoc.id;
          final token = userDoc.data()['fcmToken'];
          final isMuted = await isGroupMuted(groupId); // Check mute status for each recipient

          if (token != null && token.isNotEmpty && !isMuted) {
            final notificationTitle = 'New message in ${groupDoc.data()?['name'] ?? 'group'}';
            String notificationBody;

            if (voiceUrl != null) {
              notificationBody = '$senderName sent a 🎤 voice message';
            } else if (imageUrl != null) {
              notificationBody = '$senderName sent a 📷 photo';
            } else if (videoUrl != null) {
              notificationBody = '$senderName sent a 🎬 video';
            } else {
              notificationBody = text.isEmpty ? '' : '$senderName: ${text.length > 30 
                  ? '${text.substring(0, 30)}...' 
                  : text}';
            }

            await NotificationService.sendChatNotification(
              recipientToken: token,
              title: notificationTitle,
              body: notificationBody,
              data: {
                'type': 'group_chat',
                'groupId': groupId,
                'groupName': groupDoc.data()?['name'] ?? 'Group',
                'senderId': user.uid,
                'senderName': senderName,
                'originallyMuted': isMuted,
              },
            );
            print('Notification sent to $recipientId for message in group $groupId');
          } else {
            print('Notification not sent to $recipientId (muted: $isMuted, token: ${token != null})');
          }
        }
      }

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
                    : 'text',
        'readBy': [user.uid],
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
