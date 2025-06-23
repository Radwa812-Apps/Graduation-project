import 'package:cloud_firestore/cloud_firestore.dart';

class Group {
  final String id;
  final String name;
  final String description;
  final String? encryptedGroupPicture;
  final String? encryptionKey; 
  final Timestamp createdAt;
  final String createdBy;
  final List<String> members;

  Group({
    required this.id,
    required this.name,
    required this.description,
    required this.createdAt,
    required this.createdBy,
    required this.members,
    this.encryptedGroupPicture,
    this.encryptionKey,
  });

  factory Group.fromJson(Map<String, dynamic> json, String id) {
    return Group(
      id: id,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      encryptedGroupPicture: json['encryptedGroupPicture'],
      encryptionKey: json['encryptionKey'], 
      createdAt: json['createdAt'] ?? Timestamp.now(),
      createdBy: json['createdBy'] ?? '',
      members: List<String>.from(json['members'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'encryptedGroupPicture': encryptedGroupPicture,
      'encryptionKey': encryptionKey, 
      'createdAt': createdAt,
      'createdBy': createdBy,
      'members': members,
    };
  }
}