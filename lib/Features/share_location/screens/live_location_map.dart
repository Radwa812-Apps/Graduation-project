import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:near_me_new_version/Features/auth/Sign_up_and_in/components/custom_back_button.dart';
import 'package:near_me_new_version/Features/group_profile/screens/group_profile_screen.dart';
import 'package:near_me_new_version/Features/share_location/components/OSRMRouteMap.dart';
import 'package:near_me_new_version/Features/share_location/components/build_Bottom_Sheet_With_Avatar.dart';
import 'package:near_me_new_version/Features/share_location/components/is_tracking_on_block.dart';

class OrderTrackingPage extends StatefulWidget {
  const OrderTrackingPage({Key? key}) : super(key: key);
  @override
  State<OrderTrackingPage> createState() => OrderTrackingPageState();
  static String OrderTrackingScreenKey = '/OrderTrackingScreen';
}

class OrderTrackingPageState extends State<OrderTrackingPage> {
  LocationData? currentLocation;
  LocationData? sourceLocation;
  LocationData? destinationLocation;
  late Location location;
  bool isFirstLocation = true;
  bool isMapReady = false;
  GoogleMapController? mapController;
  LatLng _initialPosition = const LatLng(30.0444, 31.2357);
  String userName = 'Radwa';
  String lastLocatin = 'Just arrived home';
  String distance = '2.5km'; // Cairo, Egypt
  StreamSubscription<LocationData>? locationSubscription;
  bool isLiveTrackingOn = false;
  @override
  void initState() {
    super.initState();
    location = Location();
    isLiveTrackingOn = context.read<TrackingOnCubit>().state;
    toggleLiveTracking(isLiveTrackingOn);
    //updatePolyline();

    // initializeLocation();
    //setCustomMarkerIcon();
  }

  @override
  void dispose() {
    locationSubscription?.cancel();
    super.dispose();
  }

  void toggleLiveTracking(bool isEnabled) async {
    log("toggleLiveTracking called with isEnabled: $isEnabled");
    setState(() {
      isLiveTrackingOn = isEnabled;
    });
    if (isEnabled) {
      currentLocation = await location.getLocation();
      sourceLocation = currentLocation;
      context.read<TrackingOnCubit>().updateValue(isLiveTrackingOn);
      initializeLocation();
    } else {
      locationSubscription?.cancel();
      locationSubscription = null;

      setState(() {
        currentLocation = null;
        _initialPosition = const LatLng(30.0444, 31.2357);
      });
      mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(zoom: 14.0, target: _initialPosition),
        ),
      );
    }
  }

  void initializeLocation() async {
    try {
      currentLocation = await location.getLocation();
      sourceLocation = currentLocation;
      log(
        "Current Location: ${currentLocation!.latitude}, ${currentLocation!.longitude}",
      );
      // initial destination location
      destinationLocation = LocationData.fromMap({
        "latitude": 26.9943, //currentLocation?.latitude, //
        "longitude": 31.4168, //currentLocation?.longitude, //
      });

      locationSubscription = location.onLocationChanged.listen((newLoc) {
        currentLocation = newLoc;
        log(
          "Updated Location: ${currentLocation!.latitude}, ${currentLocation!.longitude}",
        );

        updatePolyline();

        if (isMapReady && mapController != null) {
          try {
            mapController!.animateCamera(
              CameraUpdate.newCameraPosition(
                CameraPosition(
                  zoom: 13.5,
                  target: LatLng(newLoc.latitude!, newLoc.longitude!),
                ),
              ),
            );
          } catch (e) {
            print("Error animating camera: $e");
          }
        }

        setState(() {});
      });
    } catch (e) {
      print("Error getting location: $e");
    }
  }

  List<LatLng> polylineCoordinates = [];

  void updatePolyline() async {
    log("updatePolyline called");
    log(
      "Current Location: ${currentLocation?.latitude}, ${currentLocation?.longitude}",
    );
    log(
      "destination Location: ${sourceLocation?.latitude}, ${sourceLocation?.longitude}",
    );
    if (currentLocation == null || sourceLocation == null) return;
    log("Fetching polyline points");
    //PolylinePoints polylinePoints = PolylinePoints();
    try {
      OSRMRouteMap osrmRouteMap = OSRMRouteMap();
      final latlong2Points = await osrmRouteMap.getRoute(
        sourceLocation!.latitude!,
        sourceLocation!.longitude!,
        currentLocation!.latitude!,
        currentLocation!.longitude!,
      );
      polylineCoordinates =
          latlong2Points
              .map((point) => LatLng(point.latitude, point.longitude))
              .toList();
      setState(() {});
      log("Number of polyline points: ${polylineCoordinates.length}");
      
    } catch (e) {
      log("Error fetching polyline points: $e");
    }
  }

  BitmapDescriptor sourceIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor destinationIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor currentLocationIcon = BitmapDescriptor.defaultMarker;
  void setCustomMarkerIcon() {
    BitmapDescriptor.fromAssetImage(
      ImageConfiguration.empty,
      "assets/Pin_source.png",
    ).then((icon) {
      sourceIcon = icon;
    });
    BitmapDescriptor.fromAssetImage(
      ImageConfiguration.empty,
      "assets/Pin_destination.png",
    ).then((icon) {
      destinationIcon = icon;
    });
    BitmapDescriptor.fromAssetImage(
      ImageConfiguration.empty,
      "assets/Badge.png",
    ).then((icon) {
      currentLocationIcon = icon;
    });
  }

  @override
  Widget build(BuildContext context) {
    final String name = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      body: Stack(
        children: [
          isLiveTrackingOn == true
              ? currentLocation == null || destinationLocation == null
                  ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text("Loading"),
                      ],
                    ),
                  )
                  : GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(
                        currentLocation!.latitude!,
                        currentLocation!.longitude!,
                      ),
                      zoom: 13.5,
                    ),
                    markers: {
                      Marker(
                        markerId: const MarkerId("currentLocation"),
                        position: LatLng(
                          currentLocation!.latitude!,
                          currentLocation!.longitude!,
                        ),
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueBlue,
                        ),
                      ),
                      Marker(
                        markerId: const MarkerId("sourceLocation"),
                        position: LatLng(
                          sourceLocation!.latitude!,
                          sourceLocation!.longitude!,
                        ),
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueRed,
                        ),
                      ),
                    },
                    onMapCreated: (controller) {
                      mapController = controller;
                      isMapReady = true;
                    },
                    polylines: {
                      Polyline(
                        polylineId: const PolylineId("route"),
                        color: Colors.blue,
                        width: 5,
                        points: polylineCoordinates,
                      ),
                      // Polyline(
                      //   polylineId: PolylineId("manual_route"),
                      //   color: Colors.blue,
                      //   width: 5,
                      //   points: [
                      //     LatLng(
                      //       sourceLocation!.latitude!,
                      //       sourceLocation!.longitude!,
                      //     ),
                      //     LatLng(
                      //       currentLocation!.latitude!,
                      //       currentLocation!.longitude!,
                      //     ),
                      //   ],
                      // ),
                    },
                  )
              : GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _initialPosition,
                  zoom: 14.0,
                ),
                markers: {
                  Marker(
                    markerId: const MarkerId('group_location'),
                    position: _initialPosition,
                    infoWindow: const InfoWindow(title: 'Group Location'),
                  ),
                },
              ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomBackButton(
                  icon: Icons.arrow_back_ios_outlined,
                  ontap: () {
                    Navigator.pop(context);
                  },
                ),
                GestureDetector(
                  onTap: () {
                    _navigateToGroupProfile(context, name);
                  },
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
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
                    ),
                  ),
                ),
              ],
            ),
          ),

          BuildBottomSheetWithAvatar(
            avatarUrl: "assets/images/group.jpg",
            userName: userName,
            lastLocatin: lastLocatin,
            distance: distance,
          ),
        ],
      ),
    );
  }

  void _navigateToGroupProfile(BuildContext context, String name) {
    Navigator.pushNamed(
      context,
      GroupProfileScreen.groupProfileScreenKey,
      arguments: {
        'name': name,
        'onToggle': toggleLiveTracking,
        'isLiveTrackingOn': isLiveTrackingOn,
      },
    );
  }
}
