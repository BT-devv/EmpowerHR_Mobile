import 'dart:convert';
import 'package:empowerhr_moblie/data/service/api_service.dart';
import 'package:http/http.dart' as http;
Future<Map<String, dynamic>> verifyOTP(String emailCompany, String otp) async {
  final credentials = {
    'emailCompany': emailCompany,
    'otp': otp,
  };

  try {
    // Gọi phương thức postReq để gửi yêu cầu xác minh OTP
    final http.Response response =
        await ApiService().postReq(credentials, 'user/verify-otp');
    final Map<String, dynamic> data = jsonDecode(response.body);

    print('Verify OTP response: ${response.body}');
    return {
      'status': response.statusCode,
      'message': data['message'] ?? 'No message provided',
    };
  } catch (error) {
    print('An error occurred during OTP verification: $error');
    return {
      'status': 500,
      'message': 'An error occurred: $error',
    };
  }
}