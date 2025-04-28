import 'dart:convert';

import 'package:empowerhr_moblie/data/models/user_model.dart';
import 'package:empowerhr_moblie/data/service/api_service.dart';

class UpdateUserUsecase {
  final ApiService _apiService;

  UpdateUserUsecase(this._apiService);

  Future<UserModel> execute(String userId, Map<String, dynamic> updatedData, String token) async {
    try {
      // Loại bỏ các trường null hoặc rỗng khỏi updatedData
      final cleanedData = updatedData..removeWhere((key, value) => value == null || value == '');

      // Tạo header với token
      final headers = {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      };

      // Gọi API PUT với header chứa token
      final endpoint = 'user/$userId';
      final response = await _apiService.putReq(cleanedData, endpoint, headers: headers);

      // Xử lý response
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success'] == true) {
          return UserModel.fromJson(jsonResponse['user']);
        } else {
          throw Exception(jsonResponse['message'] ?? 'Cập nhật không thành công');
        }
      } else if (response.statusCode == 404) {
        throw Exception('Người dùng không tồn tại.');
      } else {
        throw Exception('Có lỗi xảy ra khi cập nhật thông tin người dùng: ${response.body}');
      }
    } catch (e) {
      print('Error in UpdateUserUsecase: $e');
      rethrow;
    }
  }
}