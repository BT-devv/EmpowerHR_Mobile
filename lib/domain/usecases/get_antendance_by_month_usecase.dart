import 'dart:convert';
import 'package:empowerhr_moblie/data/service/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> getEmployeeAttendanceSummary() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token');
  String? employeeID = prefs.getString('employeeID');

  if (token == null) {
    print('Error: Token not found in SharedPreferences');
    return {'success': false, 'message': 'Token not found'};
  }
  if (employeeID == null) {
    print('Error: Employee ID not found in SharedPreferences');
    return {
      'success': false,
      'message': 'Employee ID not found in SharedPreferences',
    };
  }

  print('Current employeeID from SharedPreferences: $employeeID');
  print('Token: $token');

  try {
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
    const endpoint = 'attendance/attendance/employee-summary';

    final currentDate = DateTime.now();
    final currentYear = currentDate.year;

    final startDate = DateTime(currentYear, 1, 1).toIso8601String().split('T')[0]; 
    final endDate = DateTime(currentYear, 12, 31).toIso8601String().split('T')[0]; 

    final queryParams = {
      'employeeID': employeeID,
      'startDate': startDate,
      'endDate': endDate,
    };

    print('Query params: $queryParams');

    final response = await ApiService()
        .getReqForWorklog(endpoint, headers: headers, query: queryParams)
        .timeout(const Duration(seconds: 10), onTimeout: () {
      throw Exception('Request timed out after 10 seconds');
    });

    print('Response status code: ${response.statusCode}');
    print('Response headers: ${response.headers}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      print("Raw API Response: $responseBody");

      Map<String, dynamic> attendanceData = responseBody['data'] ?? {};
      print('Attendance summary data: $attendanceData');

      return {
        'success': true,
        'message': responseBody['message'] ??
            'Employee attendance summary retrieved successfully',
        'data': attendanceData,
      };
    } else {
      print(
          'API Error: Status code ${response.statusCode}, Response: ${response.body}');
      return {
        'success': false,
        'message': 'Failed to retrieve employee attendance summary: Status code ${response.statusCode}',
      };
    }
  } catch (error) {
    print('Error fetching employee attendance summary: $error');
    return {
      'success': false,
      'message': 'An error occurred: $error',
    };
  }
}