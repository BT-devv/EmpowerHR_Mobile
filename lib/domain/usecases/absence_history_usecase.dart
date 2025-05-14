import 'dart:convert';
import 'package:empowerhr_moblie/data/service/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> getAbsencesHistory() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token');

  if (token == null) {
    return {
      'success': false,
      'message': 'Token not found',
    };
  }

  try {
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
    const endpoint = 'absence/history';

    final response = await ApiService()
        .getReq(endpoint, headers: headers)
        .timeout(const Duration(seconds: 10), onTimeout: () {
      throw Exception('Request timed out after 10 seconds');
    });

    final responseBody = jsonDecode(response.body);
    print("Dataaaaaaaaaaaaaaaaaaaaaaaaaaaaaa:${responseBody}");
    if (response.statusCode == 200) {
      return {
        'success': true,
        'message': responseBody['message'] ?? 'Absences history retrieved successfully',
        'absences': responseBody['absences'] ?? [],
      };
    } else {
      return {
        'success': false,
        'message': responseBody['message'] ?? 'Failed to retrieve absences history',
      };
    }
  } catch (error) {
    return {
      'success': false,
      'message': 'An error occurred: $error',
    };
  }
}