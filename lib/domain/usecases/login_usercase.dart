import 'dart:convert';
import 'package:empowerhr_moblie/data/service/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Thêm shared_preferences
import 'package:http/http.dart' as http;

Future<int?> login(String email, String password) async {
  final credentials = {
    'emailCompany': email,
    'password': password,
  };

  try {
    final http.Response response =
        await ApiService().postReq(credentials, 'user/login');
    final Map<String, dynamic> data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['token']);
      await prefs.setString('idUser', data['userId']);
      await prefs.setString('employeeID', data["employeeID"]);
      print('Token saved: ${data['token']}');
      print('IDUser saved: ${data['userId']}');
      print('EmployeeID saved: ${data['employeeID']}');
      return response.statusCode;
    } else {
      print('Request failed with status: ${response.statusCode}');
      print('Request failed with message: ${response.body}');
      return response.statusCode;
    }
  } catch (error) {
    print('An error occurred during login: $error');
    rethrow;
  }
}
