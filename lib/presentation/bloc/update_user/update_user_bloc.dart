import 'package:empowerhr_moblie/domain/usecases/update_user_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'update_user_event.dart';
import 'update_user_state.dart';

class UpdateUserBloc extends Bloc<UpdateUserEvent, UpdateUserState> {
  final UpdateUserUsecase updateUserUsecase;

  UpdateUserBloc(this.updateUserUsecase) : super(UpdateUserInitial()) {
    on<UpdateUserRequested>(_onUpdateUserRequested);
  }

  Future<void> _onUpdateUserRequested(
    UpdateUserRequested event,
    Emitter<UpdateUserState> emit,
  ) async {
    emit(UpdateUserLoading());

    try {
      final updatedUser = await updateUserUsecase.execute(
        event.userId,
        event.updatedData,
        event.token,
      );
      emit(UpdateUserSuccess(updatedUser));
    } catch (e) {
      emit(UpdateUserFailure(e.toString()));
    }
  }
}