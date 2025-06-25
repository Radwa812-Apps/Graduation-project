import 'dart:math' as math;
import 'dart:developer' as dev;

import 'dart:typed_data';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_contacts/flutter_contacts.dart' as flutter_contacts;
import 'package:near_me_new_version/core/data/models/group.dart';
import 'package:permission_handler/permission_handler.dart';

class GroupService {
  // Create a new group
  Future<String?> makeNewGroup(
    String name,
    String description, {
    List<String> geofencesIds = const [], // Default empty list
  }) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("No user is logged in!");
      return null;
    }

    try {
      var groupsCollection = FirebaseFirestore.instance.collection('groups');
      var newGroup = await groupsCollection.add({
        'name': name,
        'description': description,
        'groupPicture': null,
        'createdAt': Timestamp.now(),
        'createdBy': user.uid,
        'members': [user.uid],
        'geofenceIds': geofencesIds, // Add the custom places list
        'id': '',
      });

      String groupId = newGroup.id;
      await newGroup.update({'id': groupId});

      print("New Group Created with ID: $groupId");
      return groupId;
    } catch (e) {
      print("Error creating group: $e");
      return null;
    }
  }

  // to use stream builder
  Stream<List<Group>> getMyGroupsStream() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return const Stream.empty();

    return FirebaseFirestore.instance
        .collection('groups')
        .where('members', arrayContains: currentUser.uid)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return Group.fromJson(doc.data(), doc.id);
          }).toList();
        });
  }

  // Add group to user's list
  Future<void> addGroupToUser(String groupId) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("No user is logged in!");
      return;
    }

    try {
      var userDoc = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid);
      var userData = await userDoc.get();

      if (userData.exists) {
        var userInfo = userData.data() as Map<String, dynamic>;
        List<String> currentGroups = List<String>.from(
          userInfo['groups'] ?? [],
        );
        if (!currentGroups.contains(groupId)) {
          currentGroups.add(groupId);
          await userDoc.update({'groups': currentGroups});
          print("Group added to user: $groupId");
        }
      } else {
        await userDoc.set({
          'authUid': user.uid,
          'fName': user.displayName ?? 'Unknown',
          'email': user.email ?? '',
          'phoneNumber': '123456789',
          'dateOfBirth': '',
          'role': 'not admin',
          'profilPicture': 'default.jpg',
          'lName': '',
          'groups': [groupId],
        });
        print("New user created with group: $groupId");
      }
    } catch (e) {
      print("Error adding group to user: $e");
    }
  }

  Stream<List<Group>> streamMyGroups() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Stream.empty();
    }

    return FirebaseFirestore.instance
        .collection('groups')
        .where(
          Filter.or(
            Filter('members', arrayContains: user.uid),
            Filter('createdBy', isEqualTo: user.uid),
          ),
        )
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Group.fromJson(doc.data(), doc.id))
              .toList();
        });
  }

  // Get user's groups
  Future<List<Group>> getMyGroups() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("No user is logged in!");
      return [];
    }

    try {
      var groupsQuery =
          await FirebaseFirestore.instance
              .collection('groups')
              .where('members', arrayContains: user.uid)
              .get();

      if (groupsQuery.docs.isEmpty) {
        print("No groups found for user!");
        return [];
      }

      return groupsQuery.docs
          .map<Group>((doc) => Group.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print("Error fetching groups: $e");
      return [];
    }
  }

  // Get group by ID
  Future<Group?> getGroupById(String groupId) async {
    try {
      var groupDoc =
          await FirebaseFirestore.instance
              .collection('groups')
              .doc(groupId)
              .get();

      if (!groupDoc.exists) {
        print("Group with ID $groupId does not exist!");
        return null;
      }

      return Group.fromJson(
        groupDoc.data() as Map<String, dynamic>,
        groupDoc.id,
      );
    } catch (e) {
      print("Error fetching group: $e");
      return null;
    }
  }

  // Get user data
  Future<Map<String, String>?> getUserData(String uid) async {
    try {
      var userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (!userDoc.exists) {
        print("User with UID $uid does not exist!");
        return null;
      }

      var data = userDoc.data() as Map<String, dynamic>;
      return {
        'fName': data['fName'] ?? 'Unknown',
        'lName': data['lName'] ?? '',
        'encryptedUserPicture': data['encryptedUserPicture'] ?? '',
      };
    } catch (e) {
      print("Error fetching user data: $e");
      return null;
    }
  }

  // Get all users
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      var usersSnapshot =
          await FirebaseFirestore.instance.collection('users').get();
      List<Map<String, dynamic>> users = [];
      for (var doc in usersSnapshot.docs) {
        var data = doc.data();
        users.add({
          'uid': doc.id,
          'fName': data['fName'] ?? 'Unknown',
          'lName': data['lName'] ?? '',
          'phoneNumber': data['phoneNumber'] ?? '',
        });
      }
      return users;
    } catch (e) {
      print("Error fetching users: $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getUsersFromContacts() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return [];
      }

      if (await Permission.contacts.request().isGranted) {
        List<flutter_contacts.Contact> contacts = await flutter_contacts
            .FlutterContacts.getContacts(withProperties: true);

        List<String> contactNumbers = [];
        for (var contact in contacts) {
          for (var phone in contact.phones) {
            String cleanedNumber = phone.number.replaceAll(
              RegExp(r'[^0-9+]'),
              '',
            );

            if (cleanedNumber.isNotEmpty) {
              contactNumbers.add(cleanedNumber);

              if (cleanedNumber.startsWith('+')) {
                contactNumbers.add(cleanedNumber.substring(1));
              }

              if (cleanedNumber.length > 9) {
                String withoutCountryCode = cleanedNumber.substring(
                  cleanedNumber.length - 10,
                );
                contactNumbers.add(withoutCountryCode);
              }
            }
          }
        }

        var usersSnapshot =
            await FirebaseFirestore.instance.collection('users').get();

        List<Map<String, dynamic>> matchedUsers = [];
        for (var doc in usersSnapshot.docs) {
          var data = doc.data();
          String phoneNumber = '';

          if (data['phoneNumber'] != null) {
            if (data['phoneNumber'] is Map<String, dynamic>) {
              phoneNumber = (data['phoneNumber']['number'] ?? '').toString();
              String countryCode = data['phoneNumber']['countryCode'] ?? '';
              if (countryCode.isNotEmpty &&
                  !phoneNumber.startsWith(countryCode)) {
                phoneNumber = '$countryCode$phoneNumber';
              }
            } else {
              phoneNumber = data['phoneNumber'].toString();
            }
          }

          String cleanedPhoneNumber = phoneNumber.replaceAll(
            RegExp(r'[^0-9+]'),
            '',
          );

          Set<String> possiblePhoneForms = {
            cleanedPhoneNumber,
            cleanedPhoneNumber.startsWith('+')
                ? cleanedPhoneNumber.substring(1)
                : '',
            cleanedPhoneNumber.length > 9
                ? cleanedPhoneNumber.substring(cleanedPhoneNumber.length - 10)
                : '',
          };

          possiblePhoneForms.removeWhere((e) => e.isEmpty);

          if (contactNumbers.any(
            (contactNum) => possiblePhoneForms.any(
              (form) => contactNum.endsWith(form) || form.endsWith(contactNum),
            ),
          )) {
            matchedUsers.add({
              'uid': doc.id,
              'fName': data['fName'] ?? 'Unknown',
              'lName': data['lName'] ?? '',
              'phoneNumber': cleanedPhoneNumber,
            });
          }
        }
        return matchedUsers;
      } else {
        return [];
      }
    } catch (e) {
      dev.log("Error in getUsersFromContacts: $e");
      return [];
    }
  }

  // Add members to group
  Future<void> addMembersToGroup(
    String groupId,
    List<String> memberUids,
  ) async {
    try {
      await FirebaseFirestore.instance.collection('groups').doc(groupId).update(
        {'members': FieldValue.arrayUnion(memberUids)},
      );
      print("Members added to group $groupId successfully!");
    } catch (e) {
      print("Error adding members to group: $e");
    }
  }

  // Leave group and delete if empty
  Future<void> leaveGroup(String groupId) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("No user is logged in!");
      return;
    }

    try {
      // First remove user from group members
      await FirebaseFirestore.instance.collection('groups').doc(groupId).update(
        {
          'members': FieldValue.arrayRemove([user.uid]),
        },
      );

      // Then check if group is now empty
      var groupDoc =
          await FirebaseFirestore.instance
              .collection('groups')
              .doc(groupId)
              .get();

      var groupData = groupDoc.data();
      if (groupData != null) {
        List<dynamic> members = groupData['members'] ?? [];
        if (members.isEmpty) {
          // Delete group if no members left
          await FirebaseFirestore.instance
              .collection('groups')
              .doc(groupId)
              .delete();
          print("Group $groupId deleted because it has no members left");
        }
      }

      // Remove group from user's groups list
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update(
        {
          'groups': FieldValue.arrayRemove([groupId]),
        },
      );

      print("User left group successfully");
    } catch (e) {
      print("Error leaving group: $e");
      rethrow;
    }
  }

  // image
  Future<void> uploadGroupPictureToFirestore({
    required String groupId,
    required Uint8List imageBytes,
  }) async {
    try {
      final encryptionKey = generateRandomKey();
      final encryptedImage = encryptImage(imageBytes, encryptionKey);

      await FirebaseFirestore.instance
          .collection('groups')
          .doc(groupId)
          .update({
            'encryptedGroupPicture': encryptedImage,
            'encryptionKey': encryptionKey,
            'lastUpdated': FieldValue.serverTimestamp(),
          });

      print('✅ Image uploaded and encrypted successfully');
    } catch (e) {
      print('❌ Upload error: $e');
      rethrow;
    }
  }

  // image
  Future<void> uploadUserPictureToFirestore({
    required String userId,
    required Uint8List imageBytes,
  }) async {
    try {
      final encryptionKey = generateRandomKey();
      final encryptedImage = encryptImage(imageBytes, encryptionKey);

      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'encryptedUserPicture': encryptedImage,
        'encryptionKey': encryptionKey,
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      print('✅ Image uploaded and encrypted successfully');
    } catch (e) {
      print('❌ Upload error: $e');
      rethrow;
    }
  }

  String encryptImage(Uint8List imageBytes, String keyText) {
    try {
      final key = encrypt.Key.fromUtf8(keyText);
      final iv = encrypt.IV.fromLength(16);
      final encrypter = encrypt.Encrypter(
        encrypt.AES(key, mode: encrypt.AESMode.cbc),
      );
      final encrypted = encrypter.encryptBytes(imageBytes, iv: iv);
      final combined = iv.bytes + encrypted.bytes;

      return base64Encode(combined);
    } catch (e) {
      print('❌ Encryption error: $e');
      throw Exception('Failed to encrypt image');
    }
  }

  // Download and decrypt group image
  Future<Uint8List?> getDecryptedGroupImage(String groupId) async {
    try {
      final doc =
          await FirebaseFirestore.instance
              .collection('groups')
              .doc(groupId)
              .get();

      if (doc.exists) {
        final encryptedImage = doc.data()?['encryptedGroupPicture'] as String?;
        final encryptionKey = doc.data()?['encryptionKey'] as String?;

        if (encryptedImage != null && encryptionKey != null) {
          return decryptImage(encryptedImage, encryptionKey);
        }
      }
      return null;
    } catch (e) {
      print('❌ Get image error: $e');
      return null;
    }
  }

  Uint8List _decodeAndDecryptImage(
    String encryptedBase64,
    String keyText,
    String ivBase64,
  ) {
    try {
      final encryptedBytes = base64Decode(encryptedBase64);
      final key = encrypt.Key.fromUtf8(keyText.padRight(32));
      final iv = encrypt.IV(base64Decode(ivBase64));
      final encrypter = encrypt.Encrypter(encrypt.AES(key));

      return Uint8List.fromList(
        encrypter.decryptBytes(encrypt.Encrypted(encryptedBytes), iv: iv),
      );
    } catch (e) {
      print('❌ Decryption failed: $e');
      throw Exception('Failed to decrypt image');
    }
  }

  // random key
  String generateRandomKey({int length = 32}) {
    final random = math.Random.secure();
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(
      length,
      (_) => chars[random.nextInt(chars.length)],
    ).join();
  }

  // decryption
  Uint8List decryptImage(String encryptedBase64, String keyText) {
    try {
      final combined = base64Decode(encryptedBase64);

      final iv = encrypt.IV(combined.sublist(0, 16));
      final encryptedBytes = combined.sublist(16);

      final key = encrypt.Key.fromUtf8(keyText);
      final encrypter = encrypt.Encrypter(
        encrypt.AES(key, mode: encrypt.AESMode.cbc),
      );

      return Uint8List.fromList(
        encrypter.decryptBytes(encrypt.Encrypted(encryptedBytes), iv: iv),
      );
    } catch (e) {
      print('❌ Decryption error: $e');
      throw Exception('Failed to decrypt image');
    }
  }
}
