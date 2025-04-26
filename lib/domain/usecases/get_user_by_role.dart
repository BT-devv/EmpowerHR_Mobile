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

    // Thiết lập headers với token
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    // Endpoint API
    const endpoint = 'user/users';

    // Gọi API với timeout
    final response = await ApiService()
        .getReq(endpoint, headers: headers)
        .timeout(const Duration(seconds: 10), onTimeout: () {
      throw Exception('Request timed out after 10 seconds');
    });

    // Parse response
    final List<dynamic> data = jsonDecode(response.body);

    // Kiểm tra status code
    if (response.statusCode == 200) {
      // Chuyển đổi dữ liệu thành danh sách UserModel
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
    rethrow; // Cho phép người gọi xử lý lỗi
  }
}