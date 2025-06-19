import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_contacts/flutter_contacts.dart' as flutter_contacts;
import 'package:near_me_new_version/core/data/models/group.dart';
import 'package:permission_handler/permission_handler.dart';

class GroupService {
  // Create a new group
  Future<String?> makeNewGroup(String name, String description) async {
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
        'groupPicture': 'default_picture.jpg',
        'createdAt': Timestamp.now(),
        'createdBy': user.uid,
        'members': [user.uid],
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
              .where(
                Filter.or(
                  Filter('members', arrayContains: user.uid),
                  Filter('createdBy', isEqualTo: user.uid),
                ),
              )
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
            //log("Contact: ${contact.displayName}, Phone: ${phone.number}");
            String cleanedNumber = phone.number.replaceAll(
              RegExp(r'[^0-9]'),
              '',
            );
            if (cleanedNumber.isNotEmpty) {
              contactNumbers.add(cleanedNumber);
              if (cleanedNumber.startsWith('0')) {
                contactNumbers.add('+2$cleanedNumber');
              }
              if (cleanedNumber.startsWith('20')) {
                contactNumbers.add(cleanedNumber.substring(2));
              }
            }
            log("contactNumbers: $contactNumbers");
          }
        }
        //log("Total contact numbers: ${contactNumbers.length}");
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
            RegExp(r'[^0-9]'),
            '',
          );
          //log("cleanedPhoneNumber: $cleanedPhoneNumber");

          if (contactNumbers.contains(cleanedPhoneNumber)) {
            matchedUsers.add({
              'uid': doc.id,
              'fName': data['fName'] ?? 'Unknown',
              'lName': data['lName'] ?? '',
              'phoneNumber': cleanedPhoneNumber,
            });
            //log("Matched user: ${data['fName']} ${data['lName']} with phone $cleanedPhoneNumber");
          }
        }
        //log("Total matched users: ${matchedUsers.length}");
        return matchedUsers;
      } else {
        return [];
      }
    } catch (e) {
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
}
