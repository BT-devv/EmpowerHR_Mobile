import 'dart:convert';
import 'package:empowerhr_moblie/data/service/api_service.dart';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> resetPassword(String emailCompany, String newPassword) async {
  final credentials = {
    'emailCompany': emailCompany,
    'newPassword': newPassword,
  };

  try {
    final http.Response response =
        await ApiService().postReq(credentials, 'user/reset-password');
    final Map<String, dynamic> data = jsonDecode(response.body);

    print('Reset Password response: ${response.body}');
    return {
      'status': response.statusCode,
      'message': data['message'] ?? 'No message provided',
    };
  } catch (error) {
    print('An error occurred during reset password: $error');
    return {
      'status': 500,
      'message': 'An error occurred: $error',
    };
  }
}