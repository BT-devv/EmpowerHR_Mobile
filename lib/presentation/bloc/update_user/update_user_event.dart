import 'package:equatable/equatable.dart';

abstract class UpdateUserEvent extends Equatable {
  const UpdateUserEvent();

  @override
  List<Object?> get props => [];
}

class UpdateUserRequested extends UpdateUserEvent {
  final String userId;
  final Map<String, dynamic> updatedData;
  final String token;

  const UpdateUserRequested({
    required this.userId,
    required this.updatedData,
    required this.token,
  });

  @override
  List<Object?> get props => [userId, updatedData, token];
}