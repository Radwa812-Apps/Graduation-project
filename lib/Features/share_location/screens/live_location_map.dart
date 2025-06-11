import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart' show QuerySnapshot;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:near_me_new_version/Features/auth/Sign_up_and_in/components/custom_back_button.dart';
import 'package:near_me_new_version/Features/group_profile/screens/group_profile_screen.dart';
import 'package:near_me_new_version/Features/share_location/components/build_Bottom_Sheet_With_Avatar.dart';
import 'package:near_me_new_version/Features/share_location/components/firebase_controller.dart';
import 'package:near_me_new_version/Features/share_location/components/location_controller.dart';
import 'package:near_me_new_version/Features/share_location/components/map_controller.dart';
import 'package:near_me_new_version/Features/share_location/components/map_widget.dart';

class OrderTrackingPage extends StatefulWidget {
  final String groupId;
  final String groupName;

  const OrderTrackingPage({Key? key, this.groupId = '', this.groupName = ''})
    : super(key: key);

  @override
  State<OrderTrackingPage> createState() => _OrderTrackingPageState();

  static String orderTrackingScreenKey = '/OrderTrackingScreen';
}

class _OrderTrackingPageState extends State<OrderTrackingPage> {
  final LocationController _locationController = LocationController();
  final FirebaseController _firebaseController = FirebaseController();
  final MapController _mapController = MapController();

  bool isLiveTrackingOn = false;
  firebase_auth.User? user;
  String userName = 'Radwa';
  String lastLocationText = 'Just arrived home';
  String distance = '2.5km';
  List<LatLng> polylineCoordinates = [];

  @override
  void initState() {
    super.initState();
    user = firebase_auth.FirebaseAuth.instance.currentUser;
    _initializeTracking();
  }

  Future<void> _initializeTracking() async {
    await _locationController.getInitialLocation();
    final hasLiveLocations = await _firebaseController
        .checkIfGroupHasLiveLocations(widget.groupId);

    setState(() {
      isLiveTrackingOn = hasLiveLocations ?? false;
      log("Live tracking status: $isLiveTrackingOn");
      if (_locationController.currentLocation != null) {
        _mapController.initialPosition = LatLng(
          _locationController.currentLocation!.latitude!,
          _locationController.currentLocation!.longitude!,
        );
        log("Initial position set to: ${_mapController.initialPosition}");
      }
    });

    _toggleLiveTracking(isLiveTrackingOn);
  }

  void _toggleLiveTracking(bool isEnabled) async {
    setState(() => isLiveTrackingOn = isEnabled);

    if (isEnabled) {
      _startLiveTracking();
    } else {
      _stopLiveTracking();
    }
  }

  void _startLiveTracking() {
    _locationController.startLocationUpdates((newLoc) {
      _handleLocationUpdate(newLoc);
    });

    _listenToGroupLiveLocations();
  }

  void _stopLiveTracking() {
    _locationController.stopLocationUpdates();
    _updateFirebaseLocation(false);
    _resetStaticMap();
  }

  void _handleLocationUpdate(LocationData newLoc) {
    _locationController.currentLocation = newLoc;
    _locationController.destinationLocation = newLoc;
    _updateFirebaseLocation(true);
    
    _mapController.updateCameraPosition(
      LatLng(newLoc.latitude!, newLoc.longitude!),
      zoom: 13.5,
    );
    
    setState(() {});
  }

  Future<void> _resetStaticMap() async {
    await _locationController.getInitialLocation();
    _mapController.initialPosition = LatLng(
      _locationController.currentLocation!.latitude!,
      _locationController.currentLocation!.longitude!,
    );
    log(
      "Static map reset to initial position: ${_mapController.initialPosition}",
    );
    setState(() {});
  }

  void _updateFirebaseLocation(bool isEnabled) {
    _firebaseController.updateLiveLocation(
      widget.groupId,
      user,
      isEnabled,
      _locationController.currentLocation,
      _locationController.sourceLocation,
    );
    log("Firebase location updated: $isEnabled");
  }

  void _listenToGroupLiveLocations() {
    _firebaseController.getGroupLiveLocationsStream(widget.groupId).listen((
      snapshot,
    ) {
      final markers = _createMarkersFromSnapshot(snapshot);
      _mapController.updateMarkers(markers);
      setState(() {});
    });
  }

  Set<Marker> _createMarkersFromSnapshot(QuerySnapshot snapshot) {
    final markers = <Marker>{};

    for (var doc in snapshot.docs) {
      final curLat = double.parse(doc['curLat'].toString());
      final curLng = double.parse(doc['curLng'].toString());
      final sourceLat = double.parse(doc['sourceLat'].toString());
      final sourceLng = double.parse(doc['sourceLng'].toString());
      final userId = doc.id;

      markers.addAll([
        Marker(
          markerId: MarkerId('${userId}_current'),
          position: LatLng(curLat, curLng),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
        ),
        infoWindow: InfoWindow(
            title: 'Current Location',
            snippet: 'User ID: $userId',  
          ),
        ),
        Marker(
          markerId: MarkerId('${userId}_source'),
          position: LatLng(sourceLat, sourceLng),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueRed,
          ),
          infoWindow: InfoWindow(
            title: 'Source Location',
            snippet: 'User ID: $userId',  
          ),
        ),
      ]);
    }
    log("Markers created: ${markers.length}");
    return markers;
  }

  @override
  void dispose() {
    _locationController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          MapWidget(
            isLiveTrackingOn: isLiveTrackingOn,
            currentLocation: _locationController.currentLocation,
            destinationLocation: _locationController.destinationLocation,
            sourceLocation: _locationController.sourceLocation,
            markers: _mapController.markers,
            onMapCreated: _mapController.onMapCreated,
            polylines: _createPolylines(),
            mapController: _mapController,
          ),
          _buildTopControls(),
          BuildBottomSheetWithAvatar(
            avatarUrl: "assets/images/group.jpg",
            userName: userName,
            lastLocatin: lastLocationText,
            distance: distance,
          ),
        ],
      ),
    );
  }

  Set<Polyline> _createPolylines() {
    if (_locationController.currentLocation == null ||
        _locationController.sourceLocation == null) {
      return {};
    }

    return {
      Polyline(
        polylineId: const PolylineId("manual_route"),
        points: [
          LatLng(
            _locationController.sourceLocation!.latitude!,
            _locationController.sourceLocation!.longitude!,
          ),
          LatLng(
            _locationController.currentLocation!.latitude!,
            _locationController.currentLocation!.longitude!,
          ),
        ],
      ),
    };
  }

  Widget _buildTopControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomBackButton(
            icon: Icons.arrow_back_ios_outlined,
            ontap: () => Navigator.pop(context),
          ),
          GestureDetector(
            onTap: () => _navigateToGroupProfile(context),
            child: Container(
              width: 50,
              height: 50,
              decoration: _buildGroupAvatarDecoration(),
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _buildGroupAvatarDecoration() {
    return BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(color: Colors.white, width: 4),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          blurRadius: 10,
          offset: const Offset(0, 5),
        ),
      ],
      image: const DecorationImage(
        image: AssetImage("assets/images/group.jpg"),
        fit: BoxFit.cover,
      ),
    );
  }

  void _navigateToGroupProfile(BuildContext context) {
    Navigator.pushNamed(
      context,
      GroupProfileScreen.groupProfileScreenKey,
      arguments: {
        'id': widget.groupId,
        'onToggle': _toggleLiveTracking,
        'isLiveTrackingOn': isLiveTrackingOn,
      },
    );
  }
}
