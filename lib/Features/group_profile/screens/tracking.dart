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
import 'package:near_me_new_version/Features/Map_After_SignUp/Screens/map1.dart';
import 'package:near_me_new_version/core/data/bloc/Notification/notifications_bloc.dart';
import 'package:near_me_new_version/core/data/models/notification.dart';
import 'package:near_me_new_version/core/services/Auth_functions.dart';
import 'package:near_me_new_version/core/services/location_noti.dart';
import 'package:near_me_new_version/core/services/notification_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/constants.dart' show kFontColor, kPrimaryColor1;
import '../../../core/services/get_service_key.dart';
import '../../../core/services/handle_dublicate_noti.dart';
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
  StreamSubscription<User?>? _authStateSubscription;
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
      loadTrackingState;
      _loadInitialTrackingState(userId);
    }
    _authStateSubscription = FirebaseAuth.instance.authStateChanges().listen((
      user,
    ) {
      if (user != null && mounted) {
        _loadInitialTrackingState(user.uid);
      } else if (mounted) {
        setState(() => _isTracking = false);
      }
    });
    _initLocationServices();
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    _notificationBloc.close();
    _authStateSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadInitialTrackingState(String userId) async {
    final isTracking = await loadTrackingState();
    if (mounted) {
      setState(() {
        _isTracking = isTracking;
      });
    }

    if (isTracking) {
      // If tracking was active, restart it
      await _toggleAutoTracking();
    }
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
    final newState = !_isTracking;

    if (newState) {
      // Start tracking logic
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
          distanceFilter: 5,
        ),
      ).listen((Position position) async {
        if (!mounted || !_isTracking) return;
        await _checkPositionAgainstGeofences(
          LatLng(position.latitude, position.longitude),
          isAutoTracking: true,
        );
        if (mounted) {
          setState(() => _lastPosition = position);
        }
      });
    } else {
      // Stop tracking logic
      await _positionStreamSubscription?.cancel();
      setState(() {
        _isTracking = false;
        _positionStreamSubscription = null;
      });
    }

    // Save the new state
    await saveTrackingState(newState);
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
      // Remove duplicates
      final uniqueRecipients = recipients.toSet().toList();

      print(
        '🦕 Preparing to notify ${uniqueRecipients.length} unique recipients',
      );

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

        print(
          '🦕 Sending to batch ${i ~/ batchSize + 1} (${batch.length} devices)',
        );

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
              ? "just arrived"
              : (params.event == GeofenceEvent.exit ? "just left" : "DWELL");

      final geofenceId = params.geofences.first.id;
      final currentUser = FirebaseAuth.instance.currentUser;
      final userId = currentUser?.uid;

      if (userId == null) {
        print('No authenticated user found');
        return;
      }
      // Check if we should process this event
      final geofenceIdd = params.geofences.first.id;
      if (!NotificationSentCache.shouldSendNotification(
        userId,
        geofenceIdd,
        params.event,
      )) {
        print('🦕 Duplicate geofence event - skipping');
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
          '👨🏾‍🤝‍👨🏻👨🏾‍🤝‍👨🏻👨🏾‍🤝‍👨🏻👨🏾‍🤝‍👨🏻👨🏾‍🤝‍👨🏻👨🏾‍🤝‍👨🏻👨🏾‍🤝‍👨🏻👨🏾‍🤝‍👨🏻Group ${groupDoc.id} has ${members.length} members',
        );
      }

      // Exclude current user
      allMembers.remove(userId);
      print('🦕🦕🦕🦕🦕🦕🦕🦕🦕Total recipients: ${allMembers.length}');

      // Prepare notification content
      final placeName = _extractPlaceNameFromGeofenceId(geofenceId);
      final eventVerb =
          params.event == GeofenceEvent.enter
              ? "just arrived"
              : (params.event == GeofenceEvent.exit ? "just left" : "is in");

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

      final notificationTitle = firstName;
      final notificationBody = '$eventVerb $placeName';

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

  Future<void> _showDeleteConfirmationDialog(ActiveGeofence geofence) async {
    final geofenceName = _extractPlaceNameFromGeofenceId(geofence.id);

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text(
              'Delete Geofence',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('You are about to delete:'),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    geofenceName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'This action cannot be undone.',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                style: TextButton.styleFrom(foregroundColor: Colors.grey[600]),
                child: const Text('CANCEL'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text(
                  'DELETE',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
            actionsAlignment: MainAxisAlignment.spaceBetween,
          ),
    );

    if (confirmed == true) {
      try {
        // Show loading indicator
        final overlay =
            Overlay.of(context).context.findRenderObject() as RenderBox;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => Center(child: CircularProgressIndicator()),
        );

        // Remove from native manager
        await NativeGeofenceManager.instance.removeGeofenceById(geofence.id);

        // Remove from Firestore
        final userId = FirebaseAuth.instance.currentUser?.uid;
        if (userId != null) {
          await FirebaseFirestore.instance
              .collection('userGeofences')
              .doc(userId)
              .collection('geofences')
              .doc(geofence.id)
              .delete();
        }

        // Update UI
        if (mounted) {
          setState(() {
            activeGeofences.removeWhere((g) => g.id == geofence.id);
            _geofenceStates.remove(geofence.id);
            _updateGeofenceCircles(activeGeofences);
            if (_currentGeofenceId == geofence.id) {
              _currentGeofenceId = null;
            }
          });
        }

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('"$geofenceName" deleted successfully'),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) Navigator.of(context).pop(); // Close loading dialog
      }
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
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Header with counter
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Active Geofences',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${activeGeofences.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Geofences List
                    Expanded(
                      child:
                          activeGeofences.isEmpty
                              ? LayoutBuilder(
                                builder: (context, constraints) {
                                  return SingleChildScrollView(
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                        minHeight: constraints.maxHeight,
                                      ),
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.location_off,
                                              size: 48,
                                              color: Colors.grey[400],
                                            ),
                                            const SizedBox(height: 10),
                                            Text(
                                              'No geofences added',
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 32,
                                                  ),
                                              child: GestureDetector(
                                                onTap: () {
                                                  Navigator.pushNamed(
                                                    context,
                                                    Map1.map1Key,
                                                  );
                                                },
                                                child: Text(
                                                  'Tap the map to add your first geofence',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: kPrimaryColor1,
                                                    decoration:
                                                        TextDecoration
                                                            .underline,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              )
                              : ListView.separated(
                                padding: const EdgeInsets.all(8),
                                itemCount: activeGeofences.length,
                                separatorBuilder:
                                    (context, index) =>
                                        const Divider(height: 1),
                                itemBuilder: (context, index) {
                                  final geofence = activeGeofences[index];
                                  final geofenceName =
                                      _extractPlaceNameFromGeofenceId(
                                        geofence.id,
                                      );
                                  return Card(
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 4,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(10),
                                      onTap:
                                          () => _moveCameraToGeofence(geofence),
                                      child: Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 40,
                                              height: 40,
                                              decoration: BoxDecoration(
                                                color: Theme.of(
                                                  context,
                                                ).primaryColor.withOpacity(0.1),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                Icons.location_pin,
                                                color:
                                                    Theme.of(
                                                      context,
                                                    ).primaryColor,
                                                size: 20,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    geofenceName,
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        Icons.location_on,
                                                        size: 14,
                                                        color: Colors.grey[600],
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        '${geofence.location.latitude.toStringAsFixed(4)}, '
                                                        '${geofence.location.longitude.toStringAsFixed(4)}',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color:
                                                              Colors.grey[600],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.delete_outline,
                                              ),
                                              color: Colors.red[400],
                                              onPressed:
                                                  () =>
                                                      _showDeleteConfirmationDialog(
                                                        geofence,
                                                      ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                    ),
                    // Control Buttons
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _toggleAutoTracking,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        _isTracking
                                            ? Colors.red[400]
                                            : Theme.of(context).primaryColor,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  icon: Icon(
                                    _isTracking ? Icons.stop : Icons.play_arrow,
                                  ),
                                  label: Text(
                                    _isTracking
                                        ? 'STOP TRACKING'
                                        : 'START TRACKING',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _testManualPoint,
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    side: BorderSide(
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  icon: Icon(
                                    Icons.location_searching,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  label: Text(
                                    'TEST LOCATION',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _isTracking
                                ? 'Tracking your location in background'
                                : 'Press start to begin tracking',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
