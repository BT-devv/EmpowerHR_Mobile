import 'package:empowerhr_moblie/data/models/user_model.dart';
import 'package:equatable/equatable.dart';

abstract class UpdateUserState extends Equatable {
  const UpdateUserState();

  @override
  List<Object?> get props => [];
}

class UpdateUserInitial extends UpdateUserState {}

class UpdateUserLoading extends UpdateUserState {}

class UpdateUserSuccess extends UpdateUserState {
  final UserModel updatedUser;

  const UpdateUserSuccess(this.updatedUser);

  @override
  List<Object?> get props => [updatedUser];
}

class UpdateUserFailure extends UpdateUserState {
  final String error;

  const UpdateUserFailure(this.error);

  @override
  List<Object?> get props => [error];
}