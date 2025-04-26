import 'dart:convert';
import 'package:empowerhr_moblie/data/service/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> AbsenceRequest({
  required String employeeID,
  required String type,
  required String dateFrom,
  required String dateTo,
  required String lineManagers,
  required String coworkers,
  required String reason,
}) async {
  final credentials = {
    'employeeID': employeeID,
    'type': type,
    'dateFrom': dateFrom,
    'dateTo': dateTo,
    'lineManagers': lineManagers,
    'coworkers': coworkers,
    'reason': reason,
  };
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
    const endpoint = 'absence/request';
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
    if (response.statusCode == 201) {
      return {
        'success': true,
        'message': responseBody['message'] ?? 'Request submitted successfully',
      };
    } else {
      return {
        'success': false,
        'message': responseBody['message'] ?? 'Failed to submit request',
      };
    }
  } catch (error) {
    return {
      'success': false,
      'message': 'An error occurred: $error',
    };
  }
}
