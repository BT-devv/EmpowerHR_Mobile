import 'dart:convert';
import 'package:empowerhr_moblie/data/service/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QRCodeResponse {
  final bool success;
  final String message;
  final String? qrCode;
  final String? error;

  QRCodeResponse({
    required this.success,
    required this.message,
    this.qrCode,
    this.error,
  });

  factory QRCodeResponse.fromJson(Map<String, dynamic> json) {
    return QRCodeResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      qrCode: json['qrCode'],
      error: json['error'],
    );
  }
}

Future<QRCodeResponse> getQRCode() async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? idUser = prefs.getString('idUser');

    if (token == null || idUser == null) {
      return QRCodeResponse(
        success: false,
        message: 'Token or user ID not found in SharedPreferences',
      );
    }

    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    final endpoint = 'user/qrcode/$idUser'; // Endpoint với idUser

    // Gọi phương thức getReq từ ApiService
    final response = await ApiService().getReq(endpoint, headers: headers);

    // Parse response
    final Map<String, dynamic> data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final qrCodeResponse = QRCodeResponse.fromJson(data);
      if (qrCodeResponse.success) {
        print('QR Code retrieved: ${qrCodeResponse.qrCode}');
      } else {
        print('Failed to get QR Code: ${qrCodeResponse.message}');
      }
      return qrCodeResponse;
    } else if (response.statusCode == 404) {
      return QRCodeResponse(
        success: false,
        message: 'User not found',
      );
    } else {
      print('Request failed with status: ${response.statusCode}');
      print('Response body: ${response.body}');
      return QRCodeResponse(
        success: false,
        message: 'Failed to get QR Code',
        error: data['error'] ?? 'Unknown error',
      );
    }
  } catch (error) {
    print('Error during getQRCode: $error');
    return QRCodeResponse(
      success: false,
      message: 'An error occurred while fetching QR Code',
      error: error.toString(),
    );
  }
}