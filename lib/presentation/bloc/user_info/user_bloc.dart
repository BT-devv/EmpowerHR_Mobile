import 'dart:convert';

import 'package:empowerhr_moblie/presentation/bloc/user_info/user_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:empowerhr_moblie/data/models/user_model.dart';
import 'package:empowerhr_moblie/data/service/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final ApiService apiService;

  UserBloc(this.apiService) : super(UserInitial()) {
    on<FetchUser>(_onFetchUser);
  }

  Future<void> _onFetchUser(FetchUser event, Emitter<UserState> emit) async {
    emit(UserLoading());
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? idUser = prefs.getString('idUser');

      if (idUser == null) {
        emit(UserError('User ID not found in SharedPreferences'));
        return;
      }

      String? token = prefs.getString('token');
      if (token == null) {
        emit(UserError('Token not found in SharedPreferences'));
        return;
      }

      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      final response = await apiService
          .getReq('user/$idUser', headers: headers)
          .timeout(const Duration(seconds: 10), onTimeout: () {
        throw Exception('Request timed out after 10 seconds');
      });

      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        emit(UserLoaded(UserModel.fromJson(data)));
      } else {
        emit(UserError('Failed to fetch user: ${response.statusCode} - ${response.body}'));
      }
    } catch (error) {
      emit(UserError('Error fetching user: $error'));
    }
  }
}