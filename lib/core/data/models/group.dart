
import 'package:cloud_firestore/cloud_firestore.dart';

class Group {
  final String id;
  final String name;
  final String description;
  final String groupPicture;
  final Timestamp createdAt;
  final String createdBy;

  Group(
      {required this.id,
      required this.name,
      required this.description,
      required this.groupPicture,
      required this.createdAt,
      required this.createdBy});

  factory Group.fromJson(Map<String, dynamic> json, String id) {
    return Group(
        id: id,
        name: json['name'],
        description: json['description'],
        groupPicture: json['groupPicture'],
        createdAt:json['createdAt'],
        createdBy: json['createdBy']);
  }
}
