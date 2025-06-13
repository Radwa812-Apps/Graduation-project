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
    log("Getting initial location...");
    try {
      log("trying to get initial location");
      bool serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _location.requestService();
        if (!serviceEnabled) {
          log("Location service not enabled.");
          return;
        }
      }
      PermissionStatus permissionGranted = await _location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await _location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          log("Location permission not granted.");
          return;
        }
      }
      log("...............................");
      currentLocation = await _location.getLocation();
      log("currentLocation: $currentLocation");
      sourceLocation = currentLocation;
      destinationLocation = currentLocation; // Default to current location

      log("sourceLocation: $sourceLocation");
      log("destinationLocation: $destinationLocation");
    } catch (e, stacktrace) {
      log("Error getting initial location: $e");
      log("Stacktrace: $stacktrace");
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
