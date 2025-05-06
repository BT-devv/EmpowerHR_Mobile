import 'dart:convert';
import 'package:empowerhr_moblie/data/service/api_service.dart';
import 'package:http/http.dart' as http;

Future<int?> forgotPassword(String email) async {
  final credentials = {
    'emailCompany': email,
  };

  try {
    final http.Response response =
        await ApiService().postReq(credentials, 'user/forgot-password');
    final Map<String, dynamic> data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      print('Forgot password request successful: ${response.body}');
      return response.statusCode;
    } else {
      print('Forgot password failed with status: ${response.statusCode}');
      print('Forgot password failed with message: ${response.body}');
      return response.statusCode;
    }
  } catch (error) {
    print('An error occurred during forgot password: $error');
    rethrow;
  }
}