import 'dart:convert';
import 'package:empowerhr_moblie/data/models/user_model.dart';
import 'package:empowerhr_moblie/data/service/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<List<UserModel>> getUsersByRole(String role) async {
  try {
    // Lấy token từ SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      throw Exception('Token not found in SharedPreferences');
    }

    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    const endpoint = 'user/users';

    final response = await ApiService()
        .getReq(endpoint, headers: headers)
        .timeout(const Duration(seconds: 10), onTimeout: () {
      throw Exception('Request timed out after 10 seconds');
    });

    final List<dynamic> data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      List<UserModel> users = data.map((json) => UserModel.fromJson(json)).toList();

      // Lọc người dùng theo role
      List<UserModel> filteredUsers = users.where((user) => user.role == role).toList();

      return filteredUsers;
    } else {
      throw Exception(
          'Failed to fetch users: ${response.statusCode} - ${response.body}');
    }
  } catch (error) {
    print('Error fetching users by role: $error');
    rethrow; 
  }
}