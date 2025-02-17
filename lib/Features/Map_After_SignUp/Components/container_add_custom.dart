import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:near_me_new_version/core/services/validator.dart';
import '../../../core/constants.dart';
import '../../../core/data/bloc/custom_places/custom_places_bloc.dart';
import '../../../core/messages.dart';

class ContainerAddCustom extends StatefulWidget {
  const ContainerAddCustom({
    super.key,
    required this.selectedLatLng,
    required this.markers,
  });
  final LatLng selectedLatLng;
  final Set<Marker> markers;

  @override
  State<ContainerAddCustom> createState() => _ContainerAddCustomState();
}

class _ContainerAddCustomState extends State<ContainerAddCustom> {
  final TextEditingController _textBarController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      child: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              validator: ((value) =>
                  Validator.validateEmptyField('Custom Place', value)),
              controller: _textBarController,
              decoration: InputDecoration(
                hintText: 'Enter place name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: Colors.white),
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 12.0),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear, color: kSpecialColor),
                  onPressed: () {
                    _textBarController.clear();
                  },
                ),
              ),
              onSaved: (value) {
                //  _addMarker();
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  if (_textBarController.text.isEmpty ||
                      widget.selectedLatLng == null) {
                    AppMessages().sendVerification(
                      context,
                      Colors.red.withOpacity(0.8),
                      'Please enter a place name and select a location on the map.',
                    );
                    return;
                  }
                  BlocProvider.of<CustomPlacesBloc>(context).add(
                    AddCustomPlaces(
                      latitude: widget.selectedLatLng.latitude,
                      placeName: _textBarController.text,
                      raduis: 500,
                      longitude: widget.selectedLatLng.longitude,
                      createdAt: Timestamp.now(),
                      updatedAt: Timestamp.now(),
                      // uId: FirebaseAuth.instance.currentUser!.uid,
                    ),
                  );
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kSpecialColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                padding: const EdgeInsets.symmetric(
                    horizontal: 24.0, vertical: 12.0),
              ),
              child: const Text(
                'Add',
                style: TextStyle(fontSize: 16.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
