import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:near_me_new_version/core/services/Auth_functions.dart';

import '../../models/custom_places.dart';
import '../../../services/customplace_crud_operation.dart';
part 'custom_places_event.dart';
part 'custom_places_state.dart';

class CustomPlacesBloc extends Bloc<CustomPlacesEvent, CustomPlacesState> {
  final Services services;
  List<CustomPlace> myList = [];

  CustomPlacesBloc(this.services) : super(AddCustomPlacesInitial()) {
    on<CustomPlacesEvent>((event, emit) async {
      if (event is AddCustomPlaces) {
        emit(AddCustomPlacesLoading());
        try {
          final user = FirebaseAuth.instance.currentUser;
          if (user == null) {
            emit(AddCustomPlacesFailure('User not logged in'));
            return;
          }
          CollectionReference customPlaces = FirebaseFirestore.instance
              .collection('customPlaces');

          DocumentReference documentReference = await customPlaces.add({
            'name': event.placeName,
            'latitude': event.latitude,
            'longitude': event.longitude,
            'radius': event.raduis,
          });
          try {
            final userCustomPlacesRef = FirebaseFirestore.instance.collection(
              'user_customPlaces',
            );
            userCustomPlacesRef
                .add({
                  'userId': user.uid,
                  'customPlaceId': documentReference.id,
                  'createdAt': event.createdAt,
                  'updatedAt': event.updatedAt,
                })
                .then((value) => print("user custom place added successfuly"))
                .catchError(
                  (error) => print("Failed to add user custom place: $error"),
                );
          } catch (e) {
            emit(AddCustomPlacesFailure(e.toString()));
          }

          emit(AddCustomPlacesSuccess());
        } catch (e) {
          emit(AddCustomPlacesFailure(e.toString()));
        }
      } else if (event is ShowCustomPlacesEvent) {
        emit(ShowCustomPlacesLoading());
        try {
          myList = await services.ShowCustomPlaceMethod(event.uId);
          print('_____________________ ${event.uId}');
          print(myList.length);

          emit(ShowCustomPlacesSuccess(myList));
        } catch (e) {
          emit(ShowCustomPlacesFailure(e.toString()));
        }
      } else if (event is DeleteCustomPlace) {
        emit(DeleteCustomPlacesLoading());
        try {
          await deleteUser(event.placeId);
          emit(DeleteCustomPlacesSuccess());
        } catch (e) {
          emit(DeleteCustomPlacesFailure(e.toString()));
        }
      }
    });
  }
}
