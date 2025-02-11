import 'package:empowerhr_moblie/domain/usecases/login_usercase.dart';
import 'package:empowerhr_moblie/presentation/bloc/auth/auth_event.dart';
import 'package:empowerhr_moblie/presentation/bloc/auth/auth_state.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<LoginEvent>((event, emit) async {
      emit(AuthLoading()); // Phát trạng thái loading
      try {
        // Gọi usecase login với email và password từ event
        final statusCode = await login(event.email, event.password);
        if (statusCode == 200) {
          emit(AuthSuccess(userName: event.email)); // Đăng nhập thành công
        } else if(statusCode == 401) {
          emit(AuthFailure(message: "Incorrect password."));
        }
        else if(statusCode == 404) {
          emit(AuthFailure(message: "Unknow user."));
        }else{
          emit(AuthFailure(message: "Exception from server."));
        }
      } catch (error) {
        emit(AuthFailure(message: "An unexpected error occurred."));
      }
    });

    on<LogoutEvent>((event, emit) {
      emit(AuthInitial());
    });
  }
}
