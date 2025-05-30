import 'dart:convert';
import 'package:empowerhr_moblie/data/service/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> getAbsencesHistory() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token');
  String? employeeID =
      prefs.getString('employeeID'); 
  if (token == null) {
    print('Error: Token not found in SharedPreferences');
    return {
      'success': false,
      'message': 'Token not found',
    };
  }
  if (employeeID == null) {
    print('Error: Employee ID not found in SharedPreferences');
    return {
      'success': false,
      'message': 'Employee ID not found in SharedPreferences',
    };
  }

  print('Current employeeID from SharedPreferences: $employeeID');

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
    print("Raw API Response: $responseBody");

    if (response.statusCode == 200) {
      List<dynamic> absences = responseBody['absences'] ?? [];
      print('Total absences before filtering: ${absences.length}');

      List<dynamic> filteredAbsences = absences
          .where((absence) => absence['employeeID'] == employeeID)
          .toList();

      print('Filtered absences for employeeID $employeeID: $filteredAbsences');

      return {
        'success': true,
        'message': responseBody['message'] ??
            'Absences history retrieved successfully',
        'absences': filteredAbsences,
      };
    } else {
      print(
          'API Error: Status code ${response.statusCode}, Response: $responseBody');
      return {
        'success': false,
        'message':
            responseBody['message'] ?? 'Failed to retrieve absences history',
      };
    }
  } catch (error) {
    print('Error fetching absences history: $error');
    return {
      'success': false,
      'message': 'An error occurred: $error',
    };
  }
}
