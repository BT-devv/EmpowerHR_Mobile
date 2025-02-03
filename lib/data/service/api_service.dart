import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  static String createApiUrl(String endpoint) {
    final port = dotenv.env['PORT'] ?? '3000'; // Lấy cổng từ .env
    final baseUrl = 'http://192.168.1.3:$port/api/'; // URL
    print('URL: $baseUrl$endpoint');
    return '$baseUrl$endpoint';
  }

  Future<http.Response> postReq(Map<String, dynamic> data, String endpoint) async {
    final url = createApiUrl(endpoint);
    try {
      print("Attempting to post data to $url with body: $data");
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );

      return response;
    } catch (error) {
      print('Error occurred during POST request: $error');
      rethrow;
    }
  }
}
