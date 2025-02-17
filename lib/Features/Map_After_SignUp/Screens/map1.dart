import 'dart:async';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:near_me_new_version/Features/Map_After_SignUp/Components/complete_map_ui.dart';
import '../../../core/data/bloc/custom_places/custom_places_bloc.dart';
import '../../../core/data/models/custom_places.dart';
import '../../../core/services/customplace_crud_operation.dart';
import '../../../core/messages.dart';
import '../../../core/services/map.dart';
import '../Components/container_add_custom.dart';
import '../Components/custom_botton_skip.dart';

class Map1 extends StatefulWidget {
  const Map1({super.key});
  static const String map1Key = '/Map1';

  @override
  State<Map1> createState() => _Map1State();
}

class _Map1State extends State<Map1> {
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

  Set<Marker> convertToMarkers(List<CustomPlace> customPlaces) {
    return customPlaces.map((place) {
      return Marker(
        markerId: MarkerId(place.id),
        position: LatLng(place.latitude, place.longitude),
        infoWindow: InfoWindow(title: place.name),
      );
    }).toSet();
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
    onCreatedmapController = controller;

    markers.forEach((marker) async {
      await Future.delayed(const Duration(milliseconds: 500));
      controller.showMarkerInfoWindow(marker.markerId);
    });
  }

  @override
  void initState() {
    super.initState();
    _authListener =
        FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        print("User is signed out.");
      } else {
        print("User is signed in: ${user.uid}");
      }
    });

    _loadCustomPlaces();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _authListener?.cancel();
    super.dispose();
  }

  Future<void> _loadCustomPlaces() async {
    final customPlaces = await getUserCustomPlaces();
    setState(() {
      this.customPlaces = customPlaces;
      markers = convertToMarkers(customPlaces);
    });
  }

  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  static const CameraPosition _Assuit = CameraPosition(
    target: LatLng(27.18096, 31.18368),
    zoom: 14.4746,
  );

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('GPS is not enabled, please turn it on!')),
      );
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permission denied')),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // ignore: use_build_context_synchronously
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

  @override
  Widget build(BuildContext context) {
    final markers = convertToMarkers(customPlaces);
    return BlocConsumer<CustomPlacesBloc, CustomPlacesState>(
      listener: (context, state) {
        if (state is AddCustomPlacesSuccess ||
            state is DeleteCustomPlacesSuccess) {
          isLoad = false;
          AppMessages().sendVerification(context, Colors.green.withOpacity(0.8),
              'This Custom Place added successfully 😉');
          setState(() {
            _loadCustomPlaces();
          });
        } else if (state is AddCustomPlacesFailure) {
          isLoad = false;
          AppMessages().sendVerification(
              context, Colors.red.withOpacity(0.8), state.error);
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
                      circles: circles,
                      onTap: (latLng) {
                        setState(() {
                          selectedLatLng = latLng;
                        });
                        _addCustomPlaceBottomSheet(context);
                      },
                      markers: markers,
                      mapType: MapType.normal,
                      // initialCameraPosition: _Assuit,
                      initialCameraPosition: _cameraPosition ?? _Assuit,
                      myLocationEnabled: true,
                      myLocationButtonEnabled: true,
                      onMapCreated: _onMapCreated,

                      zoomControlsEnabled: false,
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
                    )),
                Positioned(
                    bottom: 20.h, left: 270.w, right: 10.w, child: const SkipBtn()),
              ],
            ),
          ),
        );
      },
    );
  }

  void _addCustomPlaceBottomSheet(BuildContext context) {
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
            child: ContainerAddCustom(
              selectedLatLng: selectedLatLng!,
              markers: markers,
            ));
      },
    );
  }

  Future<void> getSearchedPlace(String value) async {
    LatLng? searchedPlaceLatLng = await service.getPlaceLatLng(value);
    log(searchedPlaceLatLng.toString());

    if (searchedPlaceLatLng != null) {
      await onCreatedmapController.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(
              target: LatLng(
                  searchedPlaceLatLng.latitude, searchedPlaceLatLng.longitude),
              zoom: 17.0)));
      setState(() {
        markers.clear();
        markers.add(
          Marker(
            markerId: MarkerId(searchedPlaceLatLng.toString()),
            position: LatLng(
                searchedPlaceLatLng.latitude, searchedPlaceLatLng.longitude),
            infoWindow: InfoWindow(title: value),
          ),
        );
      });
    } else {
      log('no searched place');
    }
  }

  Future<void> goToPlace(
      double latitude, double longitude, String docId) async {
    final GoogleMapController controller = await _controller.future;
    await controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(latitude, longitude),
          zoom: 40.0,
          //tilt: 60.0,
        ),
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
