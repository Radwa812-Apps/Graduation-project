/////////////////////////////////////////////////////////////////////////////

import 'dart:async';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:native_geofence/native_geofence.dart';
import 'package:near_me_new_version/Features/Map_After_SignUp/Components/complete_map_ui.dart';
import 'package:near_me_new_version/Features/Map_After_SignUp/Components/container_add_custom.dart';
import 'package:near_me_new_version/Features/Map_After_SignUp/Components/custom_botton_skip.dart';
import 'package:near_me_new_version/core/data/bloc/custom_places/custom_places_bloc.dart';
import 'package:near_me_new_version/core/data/models/custom_places.dart';
import 'package:near_me_new_version/core/messages.dart';
import 'package:near_me_new_version/core/services/customplace_crud_operation.dart';
import 'package:near_me_new_version/core/services/map.dart';
import 'package:permission_handler/permission_handler.dart';

class Map1 extends StatefulWidget {
  const Map1({super.key});
  static const String map1Key = '/Map1';

  @override
  State<Map1> createState() => _Map1State();
}

class _Map1State extends State<Map1> {
  // 1. Add geofence caching
  // 1. First, fix the cache structure (add this at class level)
  final Map<String, Geofence> _geofenceCache =
      {}; // Changed to single level map
  final Map<String, List<String>> _userGeofenceMap =
      {}; // Maps userId to geofence IDs

  // Existing variables
  List<CustomPlace> customPlaces = [];
  Set<Circle> circles = {};
  bool isLoad = false;
  LatLng? selectedLatLng;
  Set<Marker> markers = {};
  StreamSubscription<User?>? _authListener;
  CameraPosition? _cameraPosition;
  GoogleMapController? mapController;
  bool isTextBarVisible = false;
  String? markerLabelCustomPlaceName;
  final TextEditingController _textBarController = TextEditingController();
  MapServices service = MapServices(Dio());
  var onCreatedmapController;
  final TextEditingController controller = TextEditingController();
  final FocusNode focusNode = FocusNode();
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  // Geofence related variables /////////////////////////////////////////////////////////////////////////////////
  Set<Circle> _geofenceCircles = {};
  List<ActiveGeofence> activeGeofences = [];
  double geofenceRadius = 100.0; // Default radius in meters

  @override
  void initState() {
    super.initState();
    _authListener = FirebaseAuth.instance.authStateChanges().listen((
      User? user,
    ) {
      if (user == null) {
        print("User is signed out.");
      } else {
        print("User is signed in: ${user.uid}");
      }
    });
    _loadCustomPlaces();
    _getCurrentLocation();

    //Geofence  ////////////////////////////////////////////////////////////
    _initializeGeofencing();
    initializeGeofencing(FirebaseAuth.instance.currentUser?.uid ?? '');
  }

  @override
  void dispose() {
    _authListener?.cancel();
    super.dispose();
  }

  Future<void> _initializeGeofencing() async {
    // Start loading map and data immediately
    unawaited(_loadCustomPlaces());
    unawaited(_getCurrentLocation());

    _authListener = FirebaseAuth.instance.authStateChanges().listen((
      User? user,
    ) {
      if (user != null) {
        // Don't wait for frame callback - load immediately
        unawaited(initializeGeofencing(user.uid));
      } else {
        unawaited(_clearAllGeofences());
      }
    });

    // Initialize with current user if exists
    if (FirebaseAuth.instance.currentUser != null) {
      await initializeGeofencing(FirebaseAuth.instance.currentUser!.uid);
    }
  }

  // Initialize geofencing plugin
  Future<void> initializeGeofencing(String userId) async {
    try {
      await NativeGeofenceManager.instance.initialize();
      await _checkLocationPermissions();
      await _loadActiveGeofences(userId); // Load only this user's geofences
    } catch (e) {
      debugPrint('Error initializing geofencing: $e');
    }
  }

  // 4. Optimized geofence creation
  Future<void> _createGeofenceAtSelectedLocation(
    String placeName,
    String userId,
  ) async {
    if (selectedLatLng == null) return;

    final zone = Geofence(
      id:
          'geofence_${userId}_${placeName}_${DateTime.now().millisecondsSinceEpoch}',
      location: Location(
        latitude: selectedLatLng!.latitude,
        longitude: selectedLatLng!.longitude,
      ),
      radiusMeters: geofenceRadius,
      triggers: {GeofenceEvent.enter, GeofenceEvent.exit, GeofenceEvent.dwell},
      iosSettings: IosGeofenceSettings(initialTrigger: true),
      androidSettings: AndroidGeofenceSettings(
        initialTriggers: {
          GeofenceEvent.enter,
          GeofenceEvent.exit,
          GeofenceEvent.dwell,
        },
        expiration: const Duration(days: 14),
      ),
    );

    try {
      // Save to database
      await _saveGeofenceToDatabase(zone, userId);

      // Create geofence
      await NativeGeofenceManager.instance.createGeofence(
        zone,
        _geofenceTriggered,
      );

      // Update cache
      _geofenceCache[zone.id] = zone;
      _userGeofenceMap[userId] = [...?_userGeofenceMap[userId], zone.id];

      // Update UI
      if (mounted) {
        setState(() {
          activeGeofences = [
            ...activeGeofences,
            ActiveGeofence(
              id: zone.id,
              location: zone.location,
              radiusMeters: zone.radiusMeters,
              triggers: zone.triggers,
              androidSettings: zone.androidSettings,
            ),
          ];
          _updateGeofenceCircles(activeGeofences);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Geofence created for $placeName')),
        );
      }
    } catch (e) {
      debugPrint('Error creating geofence: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating geofence: ${e.toString()}')),
        );
      }
    }
  }

  // Save geofence to Firestore under user's collection
  Future<void> _saveGeofenceToDatabase(Geofence geofence, String userId) async {
    try {
      await FirebaseFirestore.instance
          .collection('userGeofences')
          .doc(userId)
          .collection('geofences')
          .doc(geofence.id)
          .set({
            'id': geofence.id,
            'userId': userId,
            'latitude': geofence.location.latitude,
            'longitude': geofence.location.longitude,
            'radius': geofence.radiusMeters,
            'placeName': geofence.id.split('_')[2],
            'createdAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      debugPrint('Error saving geofence to database: $e');
      throw Exception('Failed to save geofence');
    }
  }

  // Geofence event handler (simplified)
  @pragma('vm:entry-point')
  static Future<void> _geofenceTriggered(GeofenceCallbackParams params) async {
    final geofence = params.geofences.first;
    final parts = geofence.id.split('_');

    if (parts.length >= 3) {
      final userId = parts[1];
      final placeName = parts[2];
      debugPrint(
        'User $userId triggered geofence event: ${params.event} at $placeName',
      );

      // Here you can add user-specific logic
      // Example: Send notification to this specific user
    }
  }

  // Check and request location permissions
  Future<void> _checkLocationPermissions() async {
    var status = await Permission.locationAlways.status;
    if (!status.isGranted) {
      status = await Permission.locationAlways.request();
      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location permissions are required for geofencing'),
          ),
        );
      }
    }
  }

  // Load only the active geofences for specific user

  // 3. Optimized geofence loading
  Future<void> _loadActiveGeofences(String userId) async {
    // Check cache first
    final cachedGeofenceIds = _userGeofenceMap[userId];
    if (cachedGeofenceIds != null && cachedGeofenceIds.isNotEmpty) {
      final cachedGeofences =
          cachedGeofenceIds
              .map((id) => _geofenceCache[id])
              .whereType<Geofence>()
              .map(
                (g) => ActiveGeofence(
                  id: g.id,
                  location: g.location,
                  radiusMeters: g.radiusMeters,
                  triggers: g.triggers,
                  androidSettings: g.androidSettings,
                ),
              )
              .toList();

      if (cachedGeofences.isNotEmpty) {
        _updateGeofenceCircles(cachedGeofences);
        return;
      }
    }

    try {
      final stopwatch = Stopwatch()..start();

      // Get only from Firestore if no cache
      final querySnapshot =
          await FirebaseFirestore.instance
              .collection('userGeofences')
              .doc(userId)
              .collection('geofences')
              .orderBy('createdAt')
              .limit(50)
              .get();

      final batchGeofences = <Geofence>[];
      final newGeofenceIds = <String>[];

      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        final zone = Geofence(
          id: data['id'],
          location: Location(
            latitude: data['latitude'],
            longitude: data['longitude'],
          ),
          radiusMeters: data['radius'],
          triggers: {
            GeofenceEvent.enter,
            GeofenceEvent.exit,
            GeofenceEvent.dwell,
          },
          iosSettings: IosGeofenceSettings(initialTrigger: true),
          androidSettings: AndroidGeofenceSettings(
            initialTriggers: {
              GeofenceEvent.enter,
              GeofenceEvent.exit,
              GeofenceEvent.dwell,
            },
            expiration: const Duration(days: 14),
          ),
        );
        batchGeofences.add(zone);
        newGeofenceIds.add(zone.id);
        _geofenceCache[zone.id] = zone;
      }

      _userGeofenceMap[userId] = newGeofenceIds;

      // Register geofences in parallel
      await Future.wait(
        batchGeofences.map(
          (g) => NativeGeofenceManager.instance.createGeofence(
            g,
            _geofenceTriggered,
          ),
        ),
      );

      final activeGeofences =
          batchGeofences
              .map(
                (g) => ActiveGeofence(
                  id: g.id,
                  location: g.location,
                  radiusMeters: g.radiusMeters,
                  triggers: g.triggers,
                  androidSettings: g.androidSettings,
                ),
              )
              .toList();

      if (mounted) {
        setState(() {
          this.activeGeofences = activeGeofences;
          _updateGeofenceCircles(activeGeofences);
        });
      }

      debugPrint(
        'Loaded ${batchGeofences.length} geofences in ${stopwatch.elapsedMilliseconds}ms',
      );
    } catch (e) {
      debugPrint('Error loading geofences: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading geofences: ${e.toString()}')),
        );
      }
    }
  }

  // 5. Add cleanup method
  Future<void> _clearAllGeofences() async {
    try {
      await NativeGeofenceManager.instance.removeAllGeofences();
      if (mounted) {
        setState(() {
          activeGeofences = [];
          _geofenceCircles.clear();
        });
      }
      _geofenceCache.clear();
    } catch (e) {
      debugPrint('Error clearing geofences: $e');
    }
  }

  // Update geofence circles on map
  void _updateGeofenceCircles(List<ActiveGeofence> geofences) {
    _geofenceCircles =
        geofences.map((geofence) {
          return Circle(
            circleId: CircleId(geofence.id),
            center: LatLng(
              geofence.location.latitude,
              geofence.location.longitude,
            ),
            radius: geofence.radiusMeters,
            strokeWidth: 2,
            strokeColor: Colors.blue,
            fillColor: Colors.blue.withOpacity(0.2),
          );
        }).toSet();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final markers = convertToMarkers(customPlaces);
    return BlocConsumer<CustomPlacesBloc, CustomPlacesState>(
      listener: (context, state) {
        if (state is AddCustomPlacesSuccess ||
            state is DeleteCustomPlacesSuccess) {
          isLoad = false;
          AppMessages().sendVerification(
            context,
            Colors.green.withOpacity(0.8),
            'This Custom Place added successfully 😉',
          );
          setState(() {
            _loadCustomPlaces();
          });
        } else if (state is AddCustomPlacesFailure) {
          isLoad = false;
          AppMessages().sendVerification(
            context,
            Colors.red.withOpacity(0.8),
            state.error,
          );
        } else {
          isLoad = false;
        }
      },
      builder: (context, state) {
        return ModalProgressHUD(
          inAsyncCall: isLoad,
          child: Scaffold(
            body: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: GoogleMap(
                      circles: {...circles, ..._geofenceCircles},
                      onTap: (latLng) {
                        setState(() {
                          selectedLatLng = latLng;
                        });
                        _addCustomPlaceBottomSheet(context);
                      },
                      markers: markers,
                      mapType: MapType.normal,
                      initialCameraPosition: _cameraPosition ?? _Assuit,
                      myLocationEnabled: true,
                      myLocationButtonEnabled: true,
                      onMapCreated: (controller) {
                        _controller.complete(controller);
                        onCreatedmapController = controller;
                        markers.forEach((marker) async {
                          await Future.delayed(
                            const Duration(milliseconds: 500),
                          );
                          controller.showMarkerInfoWindow(marker.markerId);
                        });
                      },
                      zoomControlsEnabled: true,
                    ),
                  ),
                ),
                Positioned(
                  left: 10.w,
                  top: 40.h,
                  child: CompleteMapUi(
                    service: service,
                    GetSearchedPlace: getSearchedPlace,
                    controller: controller,
                    goToPlace: goToPlace,
                  ),
                ),
                if (args != 'SettingsScreen')
                  Positioned(
                    bottom: 20.h,
                    left: 270.w,
                    right: 10.w,
                    child: const SkipBtn(),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _addCustomPlaceBottomSheet(BuildContext context) {
    final TextEditingController placeNameController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: placeNameController,
                      decoration: InputDecoration(
                        labelText: 'Place Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text('Geofence Radius: ${geofenceRadius.round()} meters'),
                    Slider(
                      value: geofenceRadius,
                      min: 50,
                      max: 1000,
                      divisions: 19,
                      onChanged: (value) {
                        setState(() {
                          geofenceRadius = value;
                        });
                      },
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        if (placeNameController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Please enter a place name'),
                            ),
                          );
                          return;
                        }

                        setState(() {
                          isLoad = true;
                        });

                        try {
                          // Add custom place

                          context.read<CustomPlacesBloc>().add(
                            AddCustomPlaces(
                              latitude: selectedLatLng!.latitude,
                              longitude: selectedLatLng!.longitude,
                              createdAt: Timestamp.fromDate(DateTime.now()),
                              updatedAt: Timestamp.fromDate(DateTime.now()),
                              raduis: 100,
                              placeName: placeNameController.text,
                            ),
                          );
                          // Create geofence
                          final userId = FirebaseAuth.instance.currentUser?.uid;
                          if (userId != null) {
                            await _createGeofenceAtSelectedLocation(
                              placeNameController.text,
                              userId,
                            );
                          }

                          // await _createGeofenceAtSelectedLocation(
                          //   placeNameController.text,
                          // );

                          Navigator.pop(context);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Place and Geofence added successfully',
                              ),
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: ${e.toString()}')),
                          );
                        } finally {
                          setState(() {
                            isLoad = false;
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 50),
                      ),
                      child: Text('Add Place with Geofence'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Rest of your existing methods...
  Set<Marker> convertToMarkers(List<CustomPlace> customPlaces) {
    return customPlaces.map((place) {
      return Marker(
        markerId: MarkerId(place.id),
        position: LatLng(place.latitude, place.longitude),
        infoWindow: InfoWindow(title: place.name),
      );
    }).toSet();
  }

  Future<void> _loadCustomPlaces() async {
    final customPlaces = await getUserCustomPlaces();
    setState(() {
      this.customPlaces = customPlaces;
      markers = convertToMarkers(customPlaces);
    });
  }

  static const CameraPosition _Assuit = CameraPosition(
    target: LatLng(27.18096, 31.18368),
    zoom: 14.4746,
  );

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('GPS is not enabled, please turn it on!')),
      );
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permission denied')),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location permission permanently denied')),
      );
      return;
    }

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _cameraPosition = CameraPosition(
        target: LatLng(position.latitude, position.longitude),
        zoom: 14.4746,
      );
    });

    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_cameraPosition!));
  }

  Future<void> getSearchedPlace(String value) async {
    LatLng? searchedPlaceLatLng = await service.getPlaceLatLng(value);
    log(searchedPlaceLatLng.toString());

    if (searchedPlaceLatLng != null) {
      await onCreatedmapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(
              searchedPlaceLatLng.latitude,
              searchedPlaceLatLng.longitude,
            ),
            zoom: 17.0,
          ),
        ),
      );
      setState(() {
        markers.clear();
        markers.add(
          Marker(
            markerId: MarkerId(searchedPlaceLatLng.toString()),
            position: LatLng(
              searchedPlaceLatLng.latitude,
              searchedPlaceLatLng.longitude,
            ),
            infoWindow: InfoWindow(title: value),
          ),
        );
      });
    } else {
      log('no searched place');
    }
  }

  Future<void> goToPlace(
    double latitude,
    double longitude,
    String docId,
  ) async {
    final GoogleMapController controller = await _controller.future;
    await controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(latitude, longitude), zoom: 40.0),
      ),
    );
    controller.showMarkerInfoWindow(MarkerId(docId));

    setState(() {
      circles.clear();
      circles.add(
        Circle(
          circleId: CircleId(docId),
          radius: 2,
          center: LatLng(latitude, longitude),
          fillColor: Colors.red.withOpacity(0.3),
          strokeColor: Colors.black.withOpacity(0.2),
          strokeWidth: 2,
        ),
      );
    });
  }
}
