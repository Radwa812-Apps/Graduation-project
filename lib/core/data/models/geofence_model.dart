import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GeofenceModel {
  final String id;
  final LatLng location;
  final double radiusMeters;
  final String placeName;
  final DateTime? createdAt;

  GeofenceModel({
    required this.id,
    required this.location,
    this.radiusMeters = 100.0,
    required this.placeName,
    this.createdAt,
  });
  factory GeofenceModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return GeofenceModel(
      id: data['id'] ?? doc.id,
      location: LatLng(
        data['latitude'] ?? 0.0,
        data['longitude'] ?? 0.0,
      ),
      radiusMeters: data['radius']?.toDouble() ?? 100.0,
      placeName: data['placeName'] ?? 'No Name',
      createdAt: data['createdAt']?.toDate(),
    );
  }
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'latitude': location.latitude,
      'longitude': location.longitude,
      'radius': radiusMeters,
      'placeName': placeName,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
  Circle toGoogleMapCircle({String? circleId}) {
    return Circle(
      circleId: CircleId(circleId ?? id),
      center: location,
      radius: radiusMeters,
      strokeWidth: 2,
      strokeColor: Colors.blue,
      fillColor: Colors.blue.withOpacity(0.15),
    );
  }

  @override
  String toString() {
    return 'Geofence(id: $id, location: $location, radius: $radiusMeters, name: $placeName)';
  }
}