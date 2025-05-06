import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class SocketService {
  WebSocketChannel? _channel;
  Function(Map<String, dynamic>)? _onMessageCallback;

  void connect(String employeeID) {
    const wsUrl = 'ws://192.168.100.68:3000'; 
    try {
      print('Attempting to connect to WebSocket at: $wsUrl');
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));

      print('WebSocket connection with employeeID: $employeeID');

      _channel!.sink.add(
        jsonEncode({
          'type': 'register',
          'employeeID': employeeID,
        }),
      );


      _channel!.stream.listen(
        (message) {
          final data = jsonDecode(message);
          if (_onMessageCallback != null) {
            _onMessageCallback!(data);
          }
          if (data['type'] == 'ping_response') {
            print('WebSocket connected successfully for employeeID: $employeeID');
          }
        },
        onError: (error) {
          print('WebSocket Error: $error');
        },
        onDone: () {
          print('WebSocket connection closed');
        },
      );
    } catch (e) {
      print('Failed to connect to WebSocket: $e');
    }
  }

 

  void onMessage(Function(Map<String, dynamic>) callback) {
    _onMessageCallback = callback;
  }

  // Đóng kết nối WebSocket
  void disconnect() {
    _channel?.sink.close();
  }
}