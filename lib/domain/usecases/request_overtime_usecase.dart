import 'dart:convert';
import 'package:empowerhr_moblie/data/service/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> requestOvertime({
  required String projectManager,
  required String date,
  required String startTime,
  required String endTime,
  required String reason,
}) async {
  final credentials = {
    'projectManager': projectManager,
    'date': date,
    'startTime': startTime,
    'endTime': endTime,
    'reason': reason,
  };
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
    const endpoint = 'overtime/request'; 
    final response = await ApiService()
        .postReq2(
      credentials,
      endpoint,
      headers: headers,
    )
        .timeout(const Duration(seconds: 10), onTimeout: () {
      throw Exception('Request timed out after 10 seconds');
    });

    final responseBody = jsonDecode(response.body);
    if (response.statusCode == 200) { // Backend trả về 200 cho thành công
      return {
        'success': true,
        'message': responseBody['message'] ?? 'Overtime request submitted successfully',
      };
    } else {
      return {
        'success': false,
        'message': responseBody['message'] ?? 'Failed to submit overtime request',
      };
    }
  } catch (error) {
    return {
      'success': false,
      'message': 'An error occurred: $error',
    };
  }
}