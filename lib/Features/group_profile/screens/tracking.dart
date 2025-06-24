///😍😍😍😍😍😍😍😍😍😍😍😍😍

import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:native_geofence/native_geofence.dart';
import 'package:native_geofence/src/typedefs.dart';
import 'package:near_me_new_version/core/data/bloc/Notification/notifications_bloc.dart';
import 'package:near_me_new_version/core/data/models/notification.dart';
import 'package:near_me_new_version/core/services/location_noti.dart';
import 'package:near_me_new_version/core/services/notification_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/services/get_service_key.dart';
import '../../../core/services/send_notification_service.dart';

class TrackingScreen extends StatelessWidget {
  const TrackingScreen({super.key});
  static const String trackingMapScreenKey = '/TrackingMapScreen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Geofence Demo')),
      body: const TrackingMapScreen(),
    );
  }
}

class TrackingMapScreen extends StatefulWidget {
  const TrackingMapScreen({super.key});

  @override
  State<TrackingMapScreen> createState() => _TrackingMapScreenState();
}

class _TrackingMapScreenState extends State<TrackingMapScreen> {
  NotificationService notificationService = NotificationService();

  // save notification to firestore
  late NotificationBloc _notificationBloc;
  final NotificationRepository _notificationRepository = NotificationRepository(
    firestore: FirebaseFirestore.instance,
  );

  // Geofence state tracking
  final Map<String, bool> _geofenceStates = {};
  String? _currentGeofenceId;
  Position? _lastPosition;

  // Tracking control
  bool _isTracking = false;
  StreamSubscription<Position>? _positionStreamSubscription;

  // UI elements
  Set<Circle> _geofenceCircles = {};
  final Set<Marker> _markers = {};
  LatLng? _manualTestPoint;
  GoogleMapController? mapController;
  late GoogleMapController _mapController;

  // Services
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  List<ActiveGeofence> activeGeofences = [];

  @override
  void initState() {
    super.initState();
    notificationService.requestNotificationPermission();
   notificationService.getDeviceToken();



    _notificationBloc = NotificationBloc(repository: _notificationRepository);
    _initNotifications();
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      initializeGeofencing(userId);
    }
    _initLocationServices();
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    _notificationBloc.close();
    super.dispose();
  }

  Future<void> initializeGeofencing(String userId) async {
    try {
      await NativeGeofenceManager.instance.initialize();
      await _checkLocationPermissions();
      await _loadActiveGeofences(userId);
    } catch (e) {
      print('Error initializing geofencing: $e');
    }
  }

  Future<void> _initLocationServices() async {
    final position = await Geolocator.getLastKnownPosition();
    if (position != null) {
      _lastPosition = position;
      _checkPositionAgainstGeofences(
        LatLng(position.latitude, position.longitude),
      );
    }
  }

  Future<void> _loadActiveGeofences(String userId) async {
    try {
      await NativeGeofenceManager.instance.removeAllGeofences();

      final querySnapshot =
          await FirebaseFirestore.instance
              .collection('userGeofences')
              .doc(userId)
              .collection('geofences')
              .get();

      final List<ActiveGeofence> loadedGeofences = [];

      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        final geofence = ActiveGeofence(
          id: data['id'],
          location: Location(
            latitude: data['latitude'],
            longitude: data['longitude'],
          ),
          radiusMeters: data['radius'],
          triggers: {GeofenceEvent.enter, GeofenceEvent.exit},
          androidSettings: AndroidGeofenceSettings(
            initialTriggers: {GeofenceEvent.enter, GeofenceEvent.exit},
            expiration: Duration(days: 14),
          ),
        );

        await NativeGeofenceManager.instance.createGeofence(
          Geofence(
            id: geofence.id,
            location: geofence.location,
            radiusMeters: geofence.radiusMeters,
            triggers: geofence.triggers,
            androidSettings: geofence.androidSettings!,
            iosSettings: IosGeofenceSettings(initialTrigger: true),
          ),
          _geofenceTriggered,
        );

        loadedGeofences.add(geofence);
      }

      if (mounted) {
        setState(() {
          activeGeofences = loadedGeofences;
          _updateGeofenceCircles(loadedGeofences);
        });
      }
    } catch (e) {
      print('Error loading geofences: $e');
    }
  }

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

  // Add this method to move camera to geofence
  void _moveCameraToGeofence(ActiveGeofence geofence) {
    final latLng = LatLng(
      geofence.location.latitude,
      geofence.location.longitude,
    );
    _mapController.animateCamera(CameraUpdate.newLatLngZoom(latLng, 16));
  }

  Future<bool> _checkLocationPermissions() async {
    var status = await Permission.locationAlways.status;
    if (!status.isGranted) {
      status = await Permission.locationAlways.request();
      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permissions required')),
        );
        return false;
      }
    }
    return true;
  }

  Future<void> _initNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _toggleAutoTracking() async {
    if (_isTracking) {
      // Stop tracking
      await _positionStreamSubscription?.cancel();
      setState(() {
        _isTracking = false;
        _positionStreamSubscription = null;
      });
      return;
    }

    // Start tracking
    final hasPermission = await _checkLocationPermissions();
    if (!hasPermission) return;

    final isServiceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isServiceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enable location services')),
      );
      return;
    }

    setState(() => _isTracking = true);

    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 5, // Update when moving at least 10 meters
      ),
    ).listen((Position position) async {
      if (!mounted || !_isTracking) return;

      await _checkPositionAgainstGeofences(
        /////////////////////
        LatLng(position.latitude, position.longitude),
        isAutoTracking: true,
      );

      if (mounted) {
        setState(() => _lastPosition = position);
      }
    });
  }

  Future<void> _checkPositionAgainstGeofences(
    LatLng newLocation, {
    bool isAutoTracking = false,
  }) async {
    print('Active Geofences: ${activeGeofences.map((g) => g.id).toList()}');
    if (activeGeofences.isEmpty) return;
    print('===== New Location Update =====');
    print(
      'Current Position: ${newLocation.latitude}, ${newLocation.longitude}\n',
    );

    String? enteredGeofenceId;
    bool exitedAllGeofences = true;

    for (var geofence in activeGeofences) {
      final distance = Geolocator.distanceBetween(
        geofence.location.latitude,
        geofence.location.longitude,
        newLocation.latitude,
        newLocation.longitude,
      );

      print('''
    Geofence ID: ${geofence.id}
    Geofence Center: ${geofence.location.latitude}, ${geofence.location.longitude}
    Distance: ${distance.toStringAsFixed(2)} meters
    Radius: ${geofence.radiusMeters} meters
    ''');

      final isInside = distance <= geofence.radiusMeters;
      final previousState = _geofenceStates[geofence.id] ?? false;

      if (isInside != previousState) {
        print('STATE CHANGED: ${isInside ? 'ENTER' : 'EXIT'}');
      }
      if (isInside) {
        enteredGeofenceId = geofence.id;
        exitedAllGeofences = false;
      }

      // Only trigger events if state changed
      if (isInside != previousState) {
        final event = isInside ? GeofenceEvent.enter : GeofenceEvent.exit;

        final params = GeofenceCallbackParams(
          event: event,
          geofences: [geofence],
          location: Location(
            latitude: newLocation.latitude,
            longitude: newLocation.longitude,
          ),
        );

        await geofenceTriggered(params);
        _geofenceStates[geofence.id] = isInside;
      }

      // Handle "still inside" case
      if (isInside && previousState && !isAutoTracking) {
        await _showNotification(
          'Geofence Update',
          'Still inside geofence ${geofence.id}',
        );
      }
      print('''
        Checking Geofence: ${geofence.id}
        Distance: $distance meters
        IsInside: $isInside
        PreviousState: $previousState
      ''');
    }
    // Handle current geofence state changes
    if (enteredGeofenceId != null && enteredGeofenceId != _currentGeofenceId) {
      _currentGeofenceId = enteredGeofenceId;
    } else if (exitedAllGeofences && _currentGeofenceId != null) {
      _currentGeofenceId = null;
    }
  }

  Future<void> _testManualPoint() async {
    if (_manualTestPoint == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a point on the map first')),
      );
      return;
    }

    await _checkPositionAgainstGeofences(_manualTestPoint!);
  }

  Future<void> _showNotification(String title, String body) async {
    const androidDetails = AndroidNotificationDetails(
      'geofence_channel',
      'Geofence Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      const NotificationDetails(android: androidDetails),
    );
  }

static Future<void> _sendPushNotifications({
  required List<String> recipients,
  required String title,
  required String body,
}) async {
  try {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      print('No internet connection');
      return;
    }

    print('🦕 Preparing to notify ${recipients.length} recipients');

    // Get valid FCM tokens
    final tokens = await _fetchValidFcmTokens(recipients);

    if (tokens.isEmpty) {
      print('🦕 No valid device tokens found');
      return;
    }

    // Send in batches (FCM limit: 500 per request)
    const batchSize = 500;
    for (var i = 0; i < tokens.length; i += batchSize) {
      final batch = tokens.sublist(
        i,
        i + batchSize > tokens.length ? tokens.length : i + batchSize,
      );

      print('🦕 Sending to batch ${i ~/ batchSize + 1} (${batch.length} devices)');

      int attempts = 0;
      bool success = false;
      while (attempts < 3 && !success) {
        try {
          // Send to each token in the batch
          for (final token in batch) {
            await SendNotificationService.sendNotificationUsingApi(
              fcmToken: token,
              title: title,
              body: body,
              data: {
                'type': 'geofence_update',
                'event_timestamp': DateTime.now().toIso8601String(),
              },
            );
          }
          success = true;
        } catch (e) {
          attempts++;
          print('Attempt $attempts failed: $e');
          await Future.delayed(Duration(seconds: 2));
        }
      }
    }
  } catch (e) {
    print('🦕 Notification send error: $e');
  }
}
  @pragma('vm:entry-point')
  static Future<void> geofenceTriggered(GeofenceCallbackParams params) async {
    try {
      final eventName =
          params.event == GeofenceEvent.enter
              ? "ENTER"
              : (params.event == GeofenceEvent.exit ? "EXIT" : "DWELL");

      final geofenceId = params.geofences.first.id;
      final currentUser = FirebaseAuth.instance.currentUser;
      final userId = currentUser?.uid;

      if (userId == null) {
        print('No authenticated user found');
        return;
      }

      // Get user profile data
      String firstName = 'User';
      try {
        final userDoc =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .get();

        if (userDoc.exists) {
          firstName = userDoc.get('fName') ?? 'User';
          //   print('Retrieved user name: $firstName');
        }
      } catch (e) {
        print('Error fetching user data: $e');
      }

      // Find relevant groups
      print('🦕🦕🦕🦕🦕🦕🦕🦕🦕Querying groups for geofence: $geofenceId');
      final groupsQuery =
          await FirebaseFirestore.instance
              .collection('groups')
              .where('geofenceIds', arrayContains: geofenceId)
              .get();

      print(
        '🦕🦕🦕🦕🦕🦕🦕🦕🦕Found ${groupsQuery.docs.length} matching groups',
      );

      final matchingGroupIds = groupsQuery.docs.map((doc) => doc.id).toList();

      // Collect unique members
      final Set<String> allMembers = {};
      for (final groupDoc in groupsQuery.docs) {
        final members = List<String>.from(groupDoc['members'] ?? []);
        allMembers.addAll(members);
        print(
          '🦕🦕🦕🦕🦕🦕🦕🦕🦕Group ${groupDoc.id} has ${members.length} members',
        );
      }

      // Exclude current user
      allMembers.remove(userId);
      print('🦕🦕🦕🦕🦕🦕🦕🦕🦕Total recipients: ${allMembers.length}');

      // Prepare notification content
      final placeName = _extractPlaceNameFromGeofenceId(geofenceId);
      final eventVerb =
          params.event == GeofenceEvent.enter
              ? "entered"
              : (params.event == GeofenceEvent.exit ? "exited" : "is in");

      // Save notification locally
      final repository = NotificationRepository(
        firestore: FirebaseFirestore.instance,
      );

      final currentUserNotification = Notifications(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userLocationId: userId,
        type: 'geofence',
        messageLocation: jsonEncode({
          'userName': firstName,
          'eventType': eventName,
          'geofenceName': placeName,
          'latitude': params.location?.latitude,
          'longitude': params.location?.longitude,
          'timestamp': DateTime.now().toIso8601String(),
          'relatedGroups': matchingGroupIds,
        }),
        timeOfLocation: Timestamp.now(),
        groupsID: matchingGroupIds,
      );
      await repository.saveNotification(currentUserNotification);

      // Initialize notifications plugin
      final notificationsPlugin = FlutterLocalNotificationsPlugin();
      await notificationsPlugin.initialize(
        const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        ),
      );

      // Show local notification
      const androidDetails = AndroidNotificationDetails(
        'geofence_channel',
        'Geofence Notifications',
        importance: Importance.max,
        priority: Priority.high,
      );

      final notificationTitle = 'Geofence Event - $firstName';
      final notificationBody = '$firstName $eventVerb $placeName';

      await notificationsPlugin.show(
        params.hashCode,
        notificationTitle,
        notificationBody,
        const NotificationDetails(android: androidDetails),
      );

      // Send remote notifications
      if (allMembers.isNotEmpty) {
        await _sendPushNotifications(
          recipients: allMembers.toList(),
          title: notificationTitle,
          body: notificationBody,
        );
      }
    } catch (e) {
      print('Geofence processing error: $e');
    }
  }
 static Future<List<String>> _fetchValidFcmTokens(List<String> userIds) async {
    final List<String> validTokens = [];

    for (final userId in userIds) {
      try {
        final userDoc =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .get();

        if (userDoc.exists) {
          final token = userDoc.get('fcmToken')?.toString();

          if (token != null && token.isNotEmpty && token != 'null') {
            validTokens.add(token);
          } else {
            print('🦕🦕🦕🦕🦕🦕🦕🦕🦕Invalid token for user $userId');

            // إذا كان الـ token غير صالح، يمكنك توليد واحد جديد وتحديثه
            final newToken = await FirebaseMessaging.instance.getToken();
            if (newToken != null) {
              await _updateUserFcmToken(userId, newToken);
              validTokens.add(newToken);
              print('🦕🦕🦕🦕🦕🦕🦕🦕🦕Generated new token for user $userId');
            }
          }
        }
      } catch (e) {
        print('🦕🦕🦕🦕🦕🦕🦕🦕🦕Error fetching token for user $userId: $e');
      }
    }

    return validTokens;
  }

  static Future<void> _updateUserFcmToken(
    String userId,
    String newToken,
  ) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'fcmToken': newToken,
      });
      print('🦕🦕🦕🦕🦕🦕🦕🦕🦕Updated FCM token for user $userId');
    } catch (e) {
      print('🦕🦕🦕🦕🦕🦕🦕🦕🦕Error updating FCM token: $e');
    }
  }
 
  static void _validateFcmResponse(http.Response response) {
    try {
      // تسجيل البيانات الأساسية للاستجابة
      print('🛠️🛠️🛠️🛠️🛠️🛠️ Raw FCM Response:');
      print('Status Code: ${response.statusCode}');
      print('Headers: ${response.headers}');
      print('Body: ${response.body}');

      if (response.statusCode != 200) {
        final errorDetails = {
          'status': response.statusCode,
          'headers': response.headers,
          'body': response.body,
          'timestamp': DateTime.now().toIso8601String(),
        };

        print('❌❌❌❌❌❌ FCM Error Details:');
        print(jsonEncode(errorDetails));

        FirebaseCrashlytics.instance.log(
          'FCM API Error: ${response.statusCode} - ${response.body}',
        );

        throw Exception(
          'FCM delivery failed with status ${response.statusCode}',
        );
      }

      final responseData = jsonDecode(response.body);
      print('🔍🔍🔍🔍🔍🔍 Parsed FCM Response:');
      print('Success: ${responseData['success']}');
      print('Failure: ${responseData['failure']}');
      print('Message ID: ${responseData['multicast_id']}');

      if (responseData['failure'] > 0) {
        final errors =
            responseData['results']?.where((r) => r['error'] != null)?.toList();

        print('⚠️⚠️⚠️⚠️⚠️⚠️ Failed Deliveries Details:');
        errors?.forEach((error) {
          print('Error: ${error['error']}');
        });

        FirebaseCrashlytics.instance.recordError(
          Exception('Partial FCM delivery failure'),
          StackTrace.current,
          reason: '''
Failed for ${responseData['failure']} tokens.
Errors: ${errors?.map((e) => e['error'])?.join(', ')}
''',
        );
      }
    } catch (e, stack) {
      print('💥💥💥💥💥💥 Error processing FCM response: $e');
      print(stack.toString());
      FirebaseCrashlytics.instance.recordError(e, stack);
      rethrow;
    }
  }













  static String _extractPlaceNameFromGeofenceId(String geofenceId) {
    try {
      final parts = geofenceId.split('_');
      return parts.length >= 3 ? parts[2] : geofenceId;
    } catch (e) {
      print('Geofence ID parsing error: $e');
      return geofenceId;
    }
  }

  @pragma('vm:entry-point')
  static Future<void> _geofenceTriggered(GeofenceCallbackParams params) async {
    try {
      final geofence = params.geofences.first;
      final parts = geofence.id.split('_');

      if (parts.length >= 2) {
        final userId = parts[1];
        final currentUser = FirebaseAuth.instance.currentUser;

        if (currentUser?.uid == userId) {
          await geofenceTriggered(params);
        }
      }
    } catch (e) {
      print('Error in _geofenceTriggered: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _notificationBloc,
      child: Scaffold(
        body: Column(
          children: [
            Expanded(
              flex: 2,
              child: GoogleMap(
                onMapCreated: (controller) {
                  _mapController = controller;
                },
                initialCameraPosition: CameraPosition(
                  target:
                      _lastPosition != null
                          ? LatLng(
                            _lastPosition!.latitude,
                            _lastPosition!.longitude,
                          )
                          : const LatLng(27.1800, 31.1837),
                  zoom: 15,
                ),
                circles: _geofenceCircles,
                markers: _markers,
                myLocationEnabled: true,
                onTap: (latLng) {
                  setState(() {
                    _manualTestPoint = latLng;
                    _markers.removeWhere(
                      (m) => m.markerId.value == 'test_point',
                    );
                    _markers.add(
                      Marker(
                        markerId: const MarkerId('test_point'),
                        position: latLng,
                        infoWindow: const InfoWindow(title: 'Test Location'),
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueOrange,
                        ),
                      ),
                    );
                  });
                  // // ✅ Automatically trigger geofence test
                  // await _checkPositionAgainstGeofences(latLng);
                },
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Active Geofences (${activeGeofences.length})',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: activeGeofences.length,
                      itemBuilder: (context, index) {
                        final geofence = activeGeofences[index];
                        return ListTile(
                          title: Text('Geofence ${index + 1} (${geofence.id})'),
                          subtitle: Text(
                            'Lat: ${geofence.location.latitude.toStringAsFixed(4)}\n'
                            'Lng: ${geofence.location.longitude.toStringAsFixed(4)}\n'
                            'Radius: ${geofence.radiusMeters}m',
                          ),
                          onTap: () {
                            _moveCameraToGeofence(geofence);
                          },
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              try {
                                final userId =
                                    FirebaseAuth.instance.currentUser?.uid;

                                await NativeGeofenceManager.instance
                                    .removeGeofenceById(geofence.id);

                                await FirebaseFirestore.instance
                                    .collection('userGeofences')
                                    .doc(userId)
                                    .collection('geofences')
                                    .doc(
                                      geofence.id,
                                    ) // Use the geofence's ID as the document ID
                                    .delete();

                                // Optional: Show success message
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Geofence deleted successfully',
                                    ),
                                  ),
                                );

                                if (userId != null) {
                                  await _loadActiveGeofences(userId);
                                }
                                setState(() {
                                  _geofenceStates.remove(geofence.id);
                                  if (_currentGeofenceId == geofence.id) {
                                    _currentGeofenceId = null;
                                  }
                                });
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error: ${e.toString()}'),
                                  ),
                                );
                              }
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: _toggleAutoTracking,
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    _isTracking ? Colors.red : Colors.green,
                                minimumSize: const Size(150, 50),
                              ),
                              child: Text(
                                _isTracking
                                    ? 'Stop Tracking'
                                    : 'Start Tracking',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: _testManualPoint,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                minimumSize: const Size(150, 50),
                              ),
                              child: const Text(
                                'Test Location',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
