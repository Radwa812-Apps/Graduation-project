part of 'custom_places_bloc.dart';
class CustomPlacesEvent {}
class ShowCustomPlacesEvent extends CustomPlacesEvent {
  final String uId;
  ShowCustomPlacesEvent(this.uId);
}
class AddCustomPlaces extends CustomPlacesEvent {
  final String placeName;
  final double latitude;
  final double longitude;
  final double raduis;
  final Timestamp createdAt;
  final Timestamp updatedAt;
  AddCustomPlaces({
    required this.createdAt,
    required this.updatedAt,
    required this.raduis,
    required this.placeName,
    required this.latitude,
    required this.longitude,
  });
}

class DeleteCustomPlace extends CustomPlacesEvent {
  final String placeId;
  DeleteCustomPlace(this.placeId);
}
class UpdateCustomPlace extends CustomPlacesEvent {
  final CustomPlace place;
  UpdateCustomPlace(this.place);
}

