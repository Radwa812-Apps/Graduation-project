class CustomPlace {
  final String id;
  // final String userId;
  final String name;
  final double latitude;
  final double longitude;
  // final double radius;
  // final String notificationType;

  CustomPlace({
    required this.id,
    // required this.userId,
    required this.name,
    required this.latitude,
    required this.longitude,
    // required this.radius,
    // required this.notificationType,
  });

  factory CustomPlace.fromJson( json, String id) {
    return CustomPlace(
      id: id,
      // userId: json['userId'] as String,
      name: json['name'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      // radius: (json['radius'] as num).toDouble(),
      // notificationType: json['notificationType'] as String,
    );
  }
}
