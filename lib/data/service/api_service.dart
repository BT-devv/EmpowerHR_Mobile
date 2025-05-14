import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  static String createApiUrl(String endpoint) {
    final port = dotenv.env['PORT'] ?? '3000'; 
    final baseUrl = 'http://192.168.100.68:$port/api/'; 
    //final baseUrl = 'http://10.7.91.254:$port/api/';
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

  Future<http.Response> postReq2(
    Map<String, dynamic> data,
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    if (endpoint.isEmpty) {
      throw ArgumentError('Endpoint cannot be empty');
    }

    if (data.isEmpty) {
      throw ArgumentError('Data cannot be empty');
    }

    final url = createApiUrl(endpoint);
    try {
      print("Attempting to post data to $url with body: $data");
      print("Headers: ${headers ?? {"Content-Type": "application/json"}}");

      final response = await http
          .post(
            Uri.parse(url),
            headers: headers ?? {"Content-Type": "application/json"},
            body: jsonEncode(data),
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () =>
                throw TimeoutException('Request timed out after 10 seconds'),
          );

      print("Received response: ${response.statusCode} - ${response.body}");
      return response;
    } catch (error) {
      print('Error occurred during POST request to $url: $error');
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

  Future<http.Response> getReqForWorklog(String endpoint,
      {Map<String, String>? headers, Map<String, String>? query}) async {
    final baseUrl = createApiUrl(endpoint);

    final uri = Uri.parse(baseUrl).replace(queryParameters: query);

    try {
      print("Attempting to fetch data from $uri with headers: $headers");
      final response = await http.get(
        uri,
        headers: headers ?? {"Content-Type": "application/json"},
      );
      return response;
    } catch (error) {
      print('Error occurred during GET request: $error');
      rethrow;
    }
  }

  Future<http.Response> putReq(Map<String, dynamic> data, String endpoint,
      {Map<String, String>? headers}) async {
    final url = createApiUrl(endpoint);
    try {
      print(
          "Attempting to put data to $url with body: $data and headers: $headers");
      final response = await http.put(
        Uri.parse(url),
        headers: headers ?? {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );

      return response;
    } catch (error) {
      print('Error occurred during PUT request: $error');
      rethrow;
    }
  }
}
