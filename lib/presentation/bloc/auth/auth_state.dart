import 'package:flutter/material.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final String userName;
  AuthSuccess({required this.userName});
}

class AuthFailure extends AuthState {
  final String message;
  final Widget image;
  AuthFailure({required this.message , required this.image});
}
