part of 'profile_bloc.dart';

abstract class ProfileEvent {}

class EditUserEvent extends ProfileEvent {
  final String fName;
  final String lName;
  final String email;
  final String phoneNumber;
  final String dateOfBirth;
  EditUserEvent(
      {required this.fName,
      required this.lName,
      required this.email,
      required this.phoneNumber,
      required this.dateOfBirth});
}

class DeleteUserEvent extends ProfileEvent {
  final String email;
  final String password;

  DeleteUserEvent(this.password, this.email);
}

class ShowUserInfoEvent extends ProfileEvent {

}
