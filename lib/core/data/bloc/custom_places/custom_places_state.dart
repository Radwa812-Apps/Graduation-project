part of 'custom_places_bloc.dart';

class CustomPlacesState {}
class AddCustomPlacesInitial extends CustomPlacesState {}
class AddCustomPlacesLoading extends CustomPlacesState {}
class AddCustomPlacesSuccess extends CustomPlacesState {}
class AddCustomPlacesFailure extends CustomPlacesState {
  final String error;
  AddCustomPlacesFailure(this.error);
}

class UpdateCustomPlacesInitial extends CustomPlacesState {}
class UpdateCustomPlacesLoading extends CustomPlacesState {}
class UpdateCustomPlacesSuccess extends CustomPlacesState {}
class UpdateCustomPlacesFailure extends CustomPlacesState {
  final String error;
  UpdateCustomPlacesFailure(this.error);
}
class DeleteCustomPlacesInitial extends CustomPlacesState {}
class DeleteCustomPlacesLoading extends CustomPlacesState {}
class DeleteCustomPlacesSuccess extends CustomPlacesState {}
class DeleteCustomPlacesFailure extends CustomPlacesState {
  final String error;
  DeleteCustomPlacesFailure(this.error);
}
class ShowCustomPlacesInitial extends CustomPlacesState {}
class ShowCustomPlacesLoading extends CustomPlacesState {}
class ShowCustomPlacesSuccess extends CustomPlacesState {
  final List<CustomPlace> places;
  ShowCustomPlacesSuccess(this.places);
}
class ShowCustomPlacesFailure extends CustomPlacesState {
  final String error;
  ShowCustomPlacesFailure(this.error);
}
