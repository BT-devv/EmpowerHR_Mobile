import 'dart:convert';
import 'package:empowerhr_moblie/data/models/check_in_model.dart';
import 'package:empowerhr_moblie/data/service/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class CheckInUsecase {
  final ApiService apiService;

  CheckInUsecase(this.apiService);

  Future<CheckInResponse> execute(String employeeID) async {
    final credentials = {
      'employeeID': employeeID,
    };

    try {
      // Gửi yêu cầu POST với token trong header
      final http.Response response = await apiService.postReq(
        credentials,
        'attendance/check-in',
      );

      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return CheckInResponse.fromJson(data);
      } else {
        // Xử lý các mã lỗi cụ thể
        String errorMessage = data['message'] ?? 'Check-in failed';
        if (response.statusCode == 404) {
          errorMessage = 'Employee not found';
        }
        throw Exception('Error ${response.statusCode}: $errorMessage');
      }
    } catch (error) {
      print('An error occurred during check-in: $error');
      rethrow;
    }
  }
}
