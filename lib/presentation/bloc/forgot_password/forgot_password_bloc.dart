import 'package:bloc/bloc.dart';
import 'forgot_password_event.dart';
import 'forgot_password_state.dart';

class ForgotPasswordBloc extends Bloc<ForgotPasswordEvent, ForgotPasswordState> {
  ForgotPasswordBloc() : super(ForgotPasswordInitial()) {
    // Xử lý khi người dùng nhập email
    on<SubmitEmailEvent>((event, emit) async {
      emit(ForgotPasswordLoading());
      try {
        // Giả lập gọi API để gửi OTP
        await Future.delayed(Duration(seconds: 2));
        emit(EmailSubmittedState());
      } catch (e) {
        emit(ForgotPasswordError("Failed to send OTP"));
      }
    });

    // Xử lý khi người dùng nhập OTP
    on<VerifyOtpEvent>((event, emit) async {
      emit(ForgotPasswordLoading());
      try {
        // Giả lập xác nhận OTP
        await Future.delayed(Duration(seconds: 2));
        emit(OtpVerifiedState());
      } catch (e) {
        emit(ForgotPasswordError("Invalid OTP"));
      }
    });

    // Xử lý khi người dùng đổi mật khẩu
    on<ChangePasswordEvent>((event, emit) async {
      emit(ForgotPasswordLoading());
      try {
        // Giả lập đổi mật khẩu
        await Future.delayed(Duration(seconds: 2));
        emit(PasswordChangedState());
      } catch (e) {
        emit(ForgotPasswordError("Failed to change password"));
      }
    });
  }
}
