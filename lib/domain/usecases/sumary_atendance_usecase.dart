import 'dart:convert';
import 'package:empowerhr_moblie/data/service/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<Map<String, dynamic>> getAttendanceSummary({
  required String employeeID,
  required String startDate, // Định dạng YYYY-MM-DD
  required String endDate, // Định dạng YYYY-MM-DD
}) async {
  try {
    // Lấy token từ SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      throw Exception('Token not found in SharedPreferences');
    }

    // Tạo headers với token
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    // Tạo query parameters
    final queryParams = {
      'employeeID': employeeID,
      'startDate': startDate,
      'endDate': endDate,
    };

    // Gọi API
    final response = await ApiService()
        .postReq2(
      queryParams,
      'attendance/employee-summary',
      headers: headers,
    )
        .timeout(const Duration(seconds: 10), onTimeout: () {
      throw Exception('Request timed out after 10 seconds');
    });

    // Parse dữ liệu JSON
    final Map<String, dynamic> data = jsonDecode(response.body);
    print('Attendance Summary Response: $data');

    // Kiểm tra phản hồi
    if (response.statusCode == 200 && data['success'] == true) {
      return data['data'] as Map<String, dynamic>;
    } else {
      throw Exception(
          'Failed to fetch attendance summary: ${response.statusCode} - ${response.body}');
    }
  } catch (e) {
    print('Error fetching attendance summary: $e');
    rethrow;
  }
}
