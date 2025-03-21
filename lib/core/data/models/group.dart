import 'package:cloud_firestore/cloud_firestore.dart';
class Group {
  final String id;
  final String name;
  final String description;
  final String groupPicture;
  final Timestamp createdAt;
  final String createdBy;
  final List<String> members; 

  Group({
    required this.id,
    required this.name,
    required this.description,
    required this.groupPicture,
    required this.createdAt,
    required this.createdBy,
    required this.members, 
  });

  factory Group.fromJson(Map<String, dynamic> json, String id) {
    return Group(
      id: id,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      groupPicture: json['groupPicture'] ?? 'default_picture.jpg',
      createdAt: json['createdAt'] ?? Timestamp.now(),
      createdBy: json['createdBy'] ?? '',
      members: List<String>.from(json['members'] ?? []), 
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': this.id,
      'name': this.name,
      'description': this.description,
      'groupPicture': this.groupPicture,
      'createdAt': this.createdAt,
      'createdBy': this.createdBy,
      'members': this.members, 
    };
  }
}
