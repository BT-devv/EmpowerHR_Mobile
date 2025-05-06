import 'dart:convert';
import 'package:empowerhr_moblie/data/models/user_model.dart';
import 'package:empowerhr_moblie/data/service/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<UserModel> getUserById() async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? idUser = prefs.getString('idUser');

    if (token == null || idUser == null) {
      throw Exception('Token or user ID not found in SharedPreferences');
    }

    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    final endpoint = 'user/$idUser';

    final response = await ApiService()
        .getReq(endpoint, headers: headers)
        .timeout(const Duration(seconds: 10), onTimeout: () {
      throw Exception('Request timed out after 10 seconds');
    });

    final Map<String, dynamic> data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return UserModel.fromJson(data);
    } else {
      throw Exception(
          'Failed to fetch user: ${response.statusCode} - ${response.body}');
    }
  } catch (error) {
    print('Error fetching user by ID: $error');
    rethrow; 
  }
}