import 'package:equatable/equatable.dart';

abstract class ForgotPasswordEvent extends Equatable {
  const ForgotPasswordEvent();

  @override
  List<Object?> get props => [];
}

class SubmitEmailEvent extends ForgotPasswordEvent {
  final String email;

  const SubmitEmailEvent(this.email);

  @override
  List<Object?> get props => [email];
}

class VerifyOtpEvent extends ForgotPasswordEvent {
  final String otp;

  const VerifyOtpEvent(this.otp);

  @override
  List<Object?> get props => [otp];
}

class ChangePasswordEvent extends ForgotPasswordEvent {
  final String newPassword;

  const ChangePasswordEvent(this.newPassword);

  @override
  List<Object?> get props => [newPassword];
}
