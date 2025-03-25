part of 'auth_bloc.dart';

class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {}

class AuthFailure extends AuthState {
   final String error;
  AuthFailure(this.error);
}

class Unauthenticated extends AuthState {}
