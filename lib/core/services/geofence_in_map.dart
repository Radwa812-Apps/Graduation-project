import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:near_me_new_version/Features/Map_After_SignUp/Screens/map1.dart';
import 'package:near_me_new_version/core/messages.dart';

void confirmDelete(BuildContext context, String docId) {
  showDialog(
    context: context,
    builder:
        (context) => AlertDialog(
          title: const Text("Confirm Delete"),
          content: const Text("Are you sure you want to delete this geofence?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(color: Colors.blue)),
            ),
            TextButton(
              onPressed: () async {
                try {
                  final userId = FirebaseAuth.instance.currentUser?.uid;
                  if (userId != null) {
                    await FirebaseFirestore.instance
                        .collection('userGeofences')
                        .doc(userId)
                        .collection('geofences')
                        .doc(docId)
                        .delete();

                    Navigator.pop(context);
                    AppMessages().sendVerification(
                      context,
                      Colors.green.withOpacity(0.8),
                      'Geofence deleted successfully!',
                    );
                  }
                } catch (e) {
                  debugPrint('Error deleting geofence: $e');
                }
              },
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
  );
}

Future<void> updateGeofence(String docId, String newName) async {
  try {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    await FirebaseFirestore.instance
        .collection('userGeofences')
        .doc(userId)
        .collection('geofences')
        .doc(docId)
        .update({'placeName': newName});
  } catch (e) {
    debugPrint('Error updating geofence: $e');
    throw Exception('Failed to update geofence');
  }
}

Stream<QuerySnapshot> getUserGeofences() {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return const Stream.empty();

  return FirebaseFirestore.instance
      .collection('userGeofences')
      .doc(userId)
      .collection('geofences')
      .snapshots();
}

void showEditDialog(BuildContext context, String docId, String currentName) {
  final controller = TextEditingController(text: currentName);

  showDialog(
    context: context,
    builder: (context) {
      return Stack(
        children: [
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(color: Colors.white.withOpacity(0.3)),
          ),
          AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text("Edit Geofence Name"),
            content: TextField(
              controller: controller,
              decoration: const InputDecoration(hintText: "Enter new name"),
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      final newName = controller.text;
                      if (newName.isNotEmpty) {
                        await updateGeofence(docId, newName);
                        final state =
                            context.findAncestorStateOfType<Map1State>();
                        state?.loadCustomPlaces();
                        Navigator.pop(context);

                        AppMessages().sendVerification(
                          context,
                          Colors.green.withOpacity(0.8),
                          'Geofence updated successfully!',
                        );
                      }
                    },
                    child: const Text(
                      "Save",
                      style: TextStyle(color: Colors.green),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      );
    },
  );
}
