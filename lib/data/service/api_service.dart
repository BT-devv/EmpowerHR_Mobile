import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  static String createApiUrl(String endpoint) {
    final port = dotenv.env['PORT'] ?? '3000'; // Lấy cổng từ .env
    final baseUrl = 'http://192.168.100.68:$port/api/'; // URL
    print('URL: $baseUrl$endpoint');
    return '$baseUrl$endpoint';
  }

  Future<http.Response> postReq(
      Map<String, dynamic> data, String endpoint) async {
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

  Future<http.Response> getReq(String endpoint,
      {Map<String, String>? headers}) async {
    final url = createApiUrl(endpoint);
    try {
      print("Attempting to fetch data from $url with headers: $headers");
      final response = await http.get(
        Uri.parse(url),
        headers: headers ?? {"Content-Type": "application/json"},
      );

      return response;
    } catch (error) {
      print('Error occurred during GET request: $error');
      rethrow;
    }
  }
}
