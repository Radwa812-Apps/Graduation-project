import 'dart:async';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart' show QuerySnapshot;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:near_me_new_version/Features/share_location/components/OSRMRouteMap.dart';
import 'package:near_me_new_version/Features/share_location/components/custom_marker_map%20.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:near_me_new_version/Features/auth/Sign_up_and_in/components/custom_back_button.dart';
import 'package:near_me_new_version/Features/group_profile/screens/group_profile_screen.dart';
import 'package:near_me_new_version/Features/share_location/components/build_Bottom_Sheet_With_Avatar.dart';
import 'package:near_me_new_version/Features/share_location/components/firebase_controller.dart';
import 'package:near_me_new_version/Features/share_location/components/is_tracking_on_block.dart';
import 'package:near_me_new_version/Features/share_location/components/location_controller.dart';
import 'package:near_me_new_version/Features/share_location/components/map_controller.dart';
import 'package:near_me_new_version/Features/share_location/components/map_widget.dart';
import 'package:near_me_new_version/core/services/group_services.dart';

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
  GroupService groupService = GroupService();
  OSRMRouteMap _OSRM = OSRMRouteMap();
  bool isLiveTrackingOn = false;
  final trackingCubit = TrackingUserOnCubit();
  bool isUserLiveTrackingOn = false;
  late StreamSubscription<bool> _trackingSubscription;
  firebase_auth.User? user = firebase_auth.FirebaseAuth.instance.currentUser;
  Set<Polyline> polylineCoordinatesSet = {};
  String currentUerName = '';
  String userName = 'Radwa';
  String lastLocationText = 'Just arrived home';
  String distance = '2.5km';
  List<LatLng> polylineCoordinates = [];
  BitmapDescriptor? customUserMarkerIcon;
  BitmapDescriptor? customSourceMarkerIcon;

  @override
  void initState() {
    log("initState............");
    super.initState();
    _createFixedMarker();
    _createFixedSourceMarker();
    user = firebase_auth.FirebaseAuth.instance.currentUser;
    isUserLiveTrackingOn = context.read<TrackingUserOnCubit>().state;

    _trackingSubscription = context.read<TrackingUserOnCubit>().stream.listen((
      state,
    ) {
      if (mounted) {
        setState(() {
          isUserLiveTrackingOn = state;
        });
      }
    });
    _initializeTracking();
  }

  // void _fetchUserData(String userId) async {
  //   Map<String, dynamic>? userData;
  //   if (user != null) {
  //     final userId = user!.uid;
  //     userData = await groupService.getUserData(userId);
  //     setState(() {});
  //   }
  //   if (userData != null) {
  //     currentUerName = userData['name'] ?? 'user';
  //   } else {
  //     log("User data not found for user: ${user?.uid}");
  //   }
  // }

  Future<void> _initializeTracking() async {
    _createFixedMarker();
    _createFixedSourceMarker();
    log("Initializing live tracking for group: ${widget.groupId}");
    await _handleLiveLocation();

    _toggleLiveTracking(isLiveTrackingOn, isUserLiveTrackingOn);
  }

  Future<void> _createFixedMarker() async {
    customUserMarkerIcon = await createCircleMarkerWithImage(
      'assets/images/user_photo.jpeg',
      circleRadius: 60.0, // يمكنك تعديل الحجم
      circleColor: Colors.blueAccent,
      borderWidth: 4.0,
      borderColor: Colors.white,
    );
  }

  Future<void> _createFixedSourceMarker() async {
    customSourceMarkerIcon = await imageToBitmapDescriptor();
  }

  Future<void> _handleLiveLocation() async {
    log("Handlie live location............");
    await _locationController.getInitialLocation();
    log("Initial location fetched: ${_locationController.currentLocation}");
    log("groupId: ${widget.groupId}");
    final hasLiveLocations = await _firebaseController
        .checkIfGroupHasLiveLocations(widget.groupId);
    final hasUserLiveLocations = await _firebaseController
        .checkIfGroupHasUserLiveLocations(widget.groupId);

    setState(() {
      isLiveTrackingOn = hasLiveLocations ?? false;
      isUserLiveTrackingOn = hasUserLiveLocations ?? false;
      log("Live tracking status: $isLiveTrackingOn");
      log("User live tracking status: $isUserLiveTrackingOn");
      if (_locationController.currentLocation != null) {
        _mapController.initialPosition = LatLng(
          _locationController.currentLocation!.latitude!,
          _locationController.currentLocation!.longitude!,
        );
        log("Initial position set to: ${_mapController.initialPosition}");
      }
    });
  }

  void _toggleLiveTracking(bool isEnabled, bool userLiveTracking) async {
    log("Toggling live tracking: $isEnabled");
    setState(() => isLiveTrackingOn = isEnabled);

    if (isEnabled || userLiveTracking) {
      _startLiveTracking();
      _mapController.updateCameraPosition(
        LatLng(
          _locationController.currentLocation!.latitude!,
          _locationController.currentLocation!.longitude!,
        ),
        zoom: 13.5,
      );
    } else {
      _stopLiveTracking();
    }
  }

  void _startLiveTracking() {
    log("Starting live tracking...");
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
    log("handling location update: ${newLoc.latitude}, ${newLoc.longitude}");
    _locationController.currentLocation = newLoc;
    _locationController.destinationLocation = newLoc;
    _updateFirebaseLocation(true);

    _mapController.updateCameraPosition(
      LatLng(newLoc.latitude!, newLoc.longitude!),
      zoom: 13.5,
    );

    setState(() {});
  }

  void _resetStaticMap() async {
    await _locationController.getInitialLocation();
    _mapController.initialPosition = LatLng(
      _locationController.currentLocation!.latitude!,
      _locationController.currentLocation!.longitude!,
    );
    log(
      "Static map reset to initial position: ${_mapController.initialPosition}",
    );
    _mapController.updateCameraPosition(
      LatLng(
        _mapController.initialPosition!.latitude!,
        _mapController.initialPosition!.longitude!,
      ),
      zoom: 13.5,
    );
    setState(() {});
  }

  void _updateFirebaseLocation(bool isEnabled) {
    log("Updating Firebase location: $isEnabled");
    _firebaseController.updateLiveLocation(
      widget.groupId,
      user,
      isEnabled,
      _locationController.currentLocation,
      _locationController.sourceLocation,
    );
    log("Firebase location updated: $isEnabled");
  }

  void _hanldeLiveLocationInstance(bool isEnabled) {
    user = firebase_auth.FirebaseAuth.instance.currentUser;
    log("Handling live location instance: $isEnabled");
    log("Current user: ${user?.uid}");
    log("current location: ${_locationController.currentLocation}");
    _initializeTracking();
    if (user == null) {
      log("No user found, cannot handle live location instance.");
      return;
    }
    isUserLiveTrackingOn = isEnabled;
    if (isEnabled) {
      _firebaseController.createLiveLocationInstance(
        widget.groupId,
        user!,
        _locationController.currentLocation!,
        _locationController.sourceLocation,
      );
    } else {
      _firebaseController.deleteLiveLocationFromFirestore(widget.groupId, user);
    }

    setState(() {
      isLiveTrackingOn = isEnabled;
      log("Live tracking instance handled: $isEnabled");
    });
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
    log("Creating markers from snapshot: ${snapshot.docs.length} documents");
    final markers = <Marker>{};
    //_fetchUserData(user!.uid);
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
          icon:
              customUserMarkerIcon ??
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(
            title: 'Current Location',
            snippet: 'User ID: $userId',
          ),
        ),
        Marker(
          markerId: MarkerId('${userId}_source'),
          position: LatLng(sourceLat, sourceLng),
          icon:
              customSourceMarkerIcon ??
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: InfoWindow(
            title: 'Source Location',
            snippet: 'User ID: $userId',
          ),
        ),
      ]);
    }
    log("Markers created: ${markers.length}");
    setState(() {
      _mapController.markers = markers;
      log("MapController markers updated: ${_mapController.markers.length}");
    });
    return markers;
  }

  @override
  void dispose() {
    log("Disposing OrderTrackingPage resources...");
    _locationController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _createPolylines();
    log("Building OrderTrackingPage with groupId: ${widget.groupId}");
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
            polylines: polylineCoordinatesSet,
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

  void _createPolylines() async {
    if (_locationController.currentLocation == null ||
        _locationController.sourceLocation == null ||
        _locationController.currentLocation?.latitude == null ||
        _locationController.currentLocation?.longitude == null ||
        _locationController.sourceLocation?.latitude == null ||
        _locationController.sourceLocation?.longitude == null) {
      return;
    }

    // Get route as List<LatLng> from latlong2, convert to Google Maps LatLng
    final osrmRoute = await _OSRM.getRoute(
      _locationController.sourceLocation!.latitude!,
      _locationController.sourceLocation!.longitude!,
      _locationController.currentLocation!.latitude!,
      _locationController.currentLocation!.longitude!,
    );

    polylineCoordinates =
        osrmRoute
            .map((latLng) => LatLng(latLng.latitude, latLng.longitude))
            .toList();
    log("Polyline coordinates: $polylineCoordinates");
    polylineCoordinatesSet = {
      Polyline(
        polylineId: const PolylineId("manual_route"),
        points:
            polylineCoordinates.isNotEmpty
                ? polylineCoordinates
                : [
                  LatLng(
                    _locationController.sourceLocation!.latitude!,
                    _locationController.sourceLocation!.longitude!,
                  ),
                  LatLng(
                    _locationController.currentLocation!.latitude!,
                    _locationController.currentLocation!.longitude!,
                  ),
                ],
        color: Colors.blue,
        width: 5,
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
        'onToggle': _hanldeLiveLocationInstance,
        'isLiveTrackingOn': isUserLiveTrackingOn,
      },
    );
  }
}
