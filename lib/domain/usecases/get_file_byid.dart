import 'dart:typed_data';
import 'package:empowerhr_moblie/data/service/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:archive/archive.dart'; 

Future<Uint8List> getFileById(String fileId) async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      return Uint8List(0);
    }

    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/octet-stream',
    };

    final endpoint = 'file/$fileId';

    final response = await ApiService()
        .getReq(endpoint, headers: headers)
        .timeout(const Duration(seconds: 10), onTimeout: () {
      return http.Response('Request timed out', 408);
    });

    if (response.statusCode == 200) {
      final bodyBytes = response.bodyBytes;

      if (bodyBytes.length >= 4 &&
          bodyBytes[0] == 0x50 && 
          bodyBytes[1] == 0x4B && 
          bodyBytes[2] == 0x03 &&
          bodyBytes[3] == 0x04) { 
        
        try {
          final archive = ZipDecoder().decodeBytes(bodyBytes);
          for (final file in archive) {
            final filename = file.name.toLowerCase();

            if (filename.endsWith('.png') || filename.endsWith('.jpg') || filename.endsWith('.jpeg')) {
              final imageBytes = file.content as Uint8List;
              
              if (imageBytes.length >= 4 &&
                  ((imageBytes[0] == 0x89 && imageBytes[1] == 0x50 && imageBytes[2] == 0x4E && imageBytes[3] == 0x47) || // PNG
                  (imageBytes[0] == 0xFF && imageBytes[1] == 0xD8))) { // JPEG
                return imageBytes;
              } else {
              }
            }
          }
          return Uint8List(0); 
        } catch (e) {
          return Uint8List(0);
        }
      }

      if (bodyBytes.length >= 4 &&
          ((bodyBytes[0] == 0x89 && bodyBytes[1] == 0x50 && bodyBytes[2] == 0x4E && bodyBytes[3] == 0x47) || // PNG
          (bodyBytes[0] == 0xFF && bodyBytes[1] == 0xD8))) { // JPEG
        return bodyBytes;
      }

      print('Data is not a recognized image format');
      return Uint8List(0);
    } else {
      print('Failed to fetch file: ${response.statusCode} - ${response.body}');
      return Uint8List(0);
    }
  } catch (error) {
    print('Error fetching file by ID: $error');
    return Uint8List(0); 
  }
}