import 'dart:async';

import 'package:location/location.dart';
import 'dart:developer';

class LocationController {
  final Location _location = Location();
  LocationData? currentLocation;
  LocationData? sourceLocation;
  LocationData? destinationLocation;
  StreamSubscription<LocationData>? locationSubscription;

  Future<void> getInitialLocation() async {
    try {
      currentLocation = await _location.getLocation();
      sourceLocation = currentLocation;
      destinationLocation = currentLocation; // Default to current location
    } catch (e) {
      log("Error getting initial location: $e");
    }
  }

  Future<void> startLocationUpdates(
    Function(LocationData) onLocationChanged,
  ) async {
    locationSubscription = _location.onLocationChanged.listen(
      onLocationChanged,
    );
  }

  void stopLocationUpdates() {
    locationSubscription?.cancel();
    locationSubscription = null;
  }

  void dispose() {
    stopLocationUpdates();
  }
}
