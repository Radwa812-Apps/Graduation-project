part of 'auth_bloc.dart';

class AuthState {}

class AuthInitial extends AuthState {}

class LoginSuccess extends AuthState {}

class LoginError extends AuthState {
  final String loginError;

  LoginError(this.loginError);
}

class LoginLoading extends AuthState {}


class RegisterSuccess extends AuthState {

}

class RegisterError extends AuthState {
  final String registerError;

  RegisterError(this.registerError);
}

class RegisterLoading extends AuthState {}

class VerifiyEmail extends AuthState {
  final User user;

  VerifiyEmail({required this.user});
}
