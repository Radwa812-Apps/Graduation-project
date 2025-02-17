part of 'auth_bloc.dart';

class AuthEvent {}

class RegisterEvent extends AuthEvent {
  final String email, pass;
 

  RegisterEvent(this.email, this.pass);
}

class LoginEvent extends AuthEvent {
  final String email, pass;

  LoginEvent(this.email, this.pass);
}
