
class Location {
  final String id;
  final String userId;
  final double latitude;
  final double longitude;
  final String name;
  final String locationStatus; //  بتاعت اي دى 🧐

  Location(
      {required this.id,
      required this.userId,
      required this.latitude,
      required this.longitude,
      required this.name,
      required this.locationStatus});

  factory Location.fromJson(Map<String, dynamic> json, String id) {
    return Location(
        id: id,
        userId: json['userId'],
        latitude:( json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num ).toDouble(),
        name: json['name'],
        locationStatus: json['locationStatus']);
  }
}
