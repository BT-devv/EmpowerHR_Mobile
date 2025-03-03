import 'package:empowerhr_moblie/domain/usecases/login_usercase.dart';
import 'package:empowerhr_moblie/presentation/bloc/auth/auth_event.dart';
import 'package:empowerhr_moblie/presentation/bloc/auth/auth_state.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<LoginEvent>((event, emit) async {
      emit(AuthLoading()); // Phát trạng thái loading
      try {
        final statusCode = await login(event.email, event.password);
        if (statusCode == 200) {
          emit(AuthSuccess(userName: event.email)); 
        } else if(statusCode == 401) {
          emit(AuthFailure(message: "Incorrect Password.Please try again",image:Image.asset('assets/error1.png')));
        }
        else if(statusCode == 404) {
          emit(AuthFailure(message: " Account not found.Please try again",image:Image.asset('assets/error2.png')));
        }else{
          emit(AuthFailure(message: "Exception from server.",image:Image.asset('assets/error1.png')));
        }
      } catch (error) {
        
      }
    });

    on<LogoutEvent>((event, emit) {
      emit(AuthInitial());
    });
  }
}
