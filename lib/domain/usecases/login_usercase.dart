import 'dart:convert';
import 'package:empowerhr_moblie/data/service/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Thêm shared_preferences
import 'package:http/http.dart' as http;

Future<int?> login(String email, String password) async {
  final credentials = {
    'email': email,
    'password': password,
  };

  try {
    // Gọi phương thức postReq để gửi yêu cầu đăng nhập
    final http.Response response =
        await ApiService().postReq(credentials, 'user/login');
    final Map<String, dynamic> data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      // Lưu token vào SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['token']);
      print('Token saved: ${data['token']}');
      return response.statusCode;
    } else {
      print('Request failed with status: ${response.statusCode}');
      return response.statusCode;
    }
    
  } catch (error) {
    print('An error occurred during login: $error');
    rethrow;
  }
}
