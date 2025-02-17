part of 'profile_bloc.dart';

abstract class ProfileState {}
class ProfileInitial extends ProfileState {}
class UserInfoLoadedSuccessState extends ProfileState {
  final UserModel userModel;
  UserInfoLoadedSuccessState({required this.userModel});
}
class UserInfoLoadingState extends ProfileState {}
class UserInfoErrorState extends ProfileState {
  final String error;
  UserInfoErrorState({required this.error});
}
class UserEditedSuccessState extends ProfileState {
  final UserModel userModel;
  UserEditedSuccessState({required this.userModel});
}
class UserEditeErrorState extends ProfileState {
  final String error;
  UserEditeErrorState({required this.error});
}
class UserEditeLoadingState extends ProfileState {}
class UserDeletedSuccessState extends ProfileState{}
class UserDeleteErrorState extends ProfileState {
  final String error;
  UserDeleteErrorState({required this.error});
}
class UserDeleteLoadingState extends ProfileState {}
