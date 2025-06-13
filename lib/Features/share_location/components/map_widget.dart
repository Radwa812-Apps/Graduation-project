import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:near_me_new_version/Features/share_location/components/custom_marker_map%20.dart';
import 'package:near_me_new_version/Features/share_location/components/location_controller.dart';
import 'package:near_me_new_version/Features/share_location/components/map_controller.dart';

class MapWidget extends StatefulWidget {
  final bool isLiveTrackingOn;
  final LocationData? currentLocation;
  final LocationData? destinationLocation;
  final LocationData? sourceLocation;
  final Set<Marker> markers;
  final Function(GoogleMapController) onMapCreated;
  final Set<Polyline> polylines;
  final MapController mapController;

  const MapWidget({
    super.key,
    required this.isLiveTrackingOn,
    required this.currentLocation,
    required this.destinationLocation,
    required this.sourceLocation,
    required this.markers,
    required this.onMapCreated,
    required this.polylines,
    required this.mapController,
  });

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  BitmapDescriptor? customSourceMarkerIcon;

  Future<void> _createFixedSourceMarker() async {
    customSourceMarkerIcon = await imageToBitmapDescriptor();
  }

  void _createPolylines() {
    // TODO: Implement polyline creation logic if needed.
    // This is a placeholder to resolve the missing method error.
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLiveTrackingOn) {
      log("building live tracking map");

      return _buildLiveTrackingMap();
    } else {
      log("building static map");
      return _buildStaticMap();
    }
  }

  Widget _buildLiveTrackingMap() {
    log("Current Location: ${widget.currentLocation}");
    log("Destination Location: ${widget.destinationLocation}");
    _createPolylines();
    //_initializeTracking();
    if (widget.currentLocation == null || widget.destinationLocation == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text("Loading"),
          ],
        ),
      );
    }

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: LatLng(
          widget.currentLocation!.latitude!,
          widget.currentLocation!.longitude!,
        ),
        zoom: 13.5,
      ),
      markers: widget.markers,
      onMapCreated: widget.onMapCreated,
      polylines: widget.polylines,
    );
  }

  Widget _buildStaticMap() {
    //final MapController _mapController = MapController();

    log("markers: ${widget.markers}");
    log("initial position: ${widget.mapController.initialPosition}");
    widget.mapController.updateCameraPosition(
      LatLng(
        widget.mapController.initialPosition!.latitude!,
        widget.mapController.initialPosition!.longitude!,
      ),
      zoom: 13.5,
    );
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: widget.mapController.initialPosition,
        zoom: 14.0,
      ),
      markers: {
        Marker(
          markerId: const MarkerId('My_location'),
          position: widget.mapController.initialPosition,
          infoWindow: const InfoWindow(title: 'your Location'),
          icon:
              customSourceMarkerIcon ??
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      },
      onMapCreated: widget.onMapCreated,
    );
  }
}
