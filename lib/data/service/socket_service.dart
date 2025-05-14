import 'dart:async';
import 'dart:convert';
import 'package:empowerhr_moblie/data/models/noti_model.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  WebSocketChannel? _channel;
  List<NotificationModel> _notifications = [];
  final StreamController<List<NotificationModel>> _notificationController =
      StreamController.broadcast();
  Stream<List<NotificationModel>> get notificationStream =>
      _notificationController.stream;

  Timer? _pingTimer; // Timer để gửi ping
  String? _currentEmployeeID; // Lưu employeeID để reconnect
  bool _isLoggedOut = false; // Trạng thái logout

  Future<void> init(String employeeID) async {
    _currentEmployeeID = employeeID;
    _isLoggedOut = false; // Reset trạng thái logout
    await _loadNotifications();
    _connectSocket(employeeID);
  }

  Future<void> _loadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString('notifications');
    if (stored != null) {
      final List<dynamic> jsonList = jsonDecode(stored);
      _notifications = jsonList
          .map((json) => NotificationModel.fromJson(json))
          .toList();
      _notificationController.add(_notifications);
      print('Loaded notifications: ${_notifications.length}');
    } else {
      print('No stored notifications found');
    }
  }

  Future<void> _saveNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('notifications', jsonEncode(_notifications));
    _notificationController.add(_notifications);
    print('Saved notifications: ${_notifications.map((n) => n.toJson())}');
  }

  void _connectSocket(String employeeID) {
    const wsUrl = 'ws://192.168.100.68:3000'; // Thay đổi theo server thực tế
    try {
      print('Attempting to connect to WebSocket at: $wsUrl');
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      _channel!.sink.add(jsonEncode({'type': 'register', 'employeeID': employeeID}));
      print('Sent register message: {"type": "register", "employeeID": "$employeeID"}');

      // Bắt đầu gửi ping định kỳ
      _startPing();

      _channel!.stream.listen(
        (message) {
          print('Raw WebSocket message received: $message');
          try {
            final data = jsonDecode(message);
            print('Decoded WebSocket message: $data');
            if (data['type'] != null && data['message'] != null) {
              final newNotification = NotificationModel(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                category: data['type'],
                description: data['message'],
                hour: _formatTime(DateTime.now()),
                date: _formatDate(DateTime.now()),
                color: _getColor(data['type']),
                read: false,
                data: data['data'],
              );
              print('New notification created: ${newNotification.toJson()}');
              _notifications.insert(0, newNotification);
              _saveNotifications();
            } else {
              print('Invalid message format: $data');
            }
          } catch (e) {
            print('Error parsing message: $e');
          }
        },
        onError: (error) {
          print('WebSocket Error: $error');
          if (!_isLoggedOut) {
            _reconnect(employeeID); // Reconnect nếu chưa logout
          }
        },
        onDone: () {
          print('WebSocket closed');
          if (!_isLoggedOut) {
            _reconnect(employeeID); // Reconnect nếu chưa logout
          }
        },
        cancelOnError: false,
      );
    } catch (e) {
      print('Failed to connect to WebSocket: $e');
      if (!_isLoggedOut) {
        _reconnect(employeeID); // Reconnect nếu chưa logout
      }
    }
  }

  void _startPing() {
    _pingTimer?.cancel(); // Hủy timer cũ nếu có
    _pingTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      if (_channel != null && _channel!.sink != null && !_isLoggedOut) {
        _channel!.sink.add(jsonEncode({'type': 'ping'}));
        print('Sent ping to keep WebSocket alive');
      } else {
        timer.cancel(); // Dừng ping nếu không có kết nối hoặc đã logout
        print('Stopped ping: WebSocket channel is null or user logged out');
      }
    });
  }

  void _reconnect(String employeeID) {
    if (_isLoggedOut) {
      print('User logged out, not reconnecting');
      return;
    }
    if (_channel != null) {
      _channel!.sink.close(); // Đóng kết nối cũ
    }
    Future.delayed(const Duration(seconds: 5), () {
      print('Attempting to reconnect for employeeID: $employeeID...');
      _channel = null; // Reset channel
      _connectSocket(employeeID); // Thử kết nối lại
    });
  }

  void sendNotification(String type, String message, Map<String, dynamic>? data) {
    if (_channel != null && _channel!.sink != null) {
      _channel!.sink.add(jsonEncode({
        'type': type,
        'message': message,
        'data': data,
      }));
      print('Sent notification: {"type": "$type", "message": "$message", "data": $data}');
    } else {
      print('Cannot send notification: WebSocket channel is null or closed');
      if (_currentEmployeeID != null && !_isLoggedOut) {
        _reconnect(_currentEmployeeID!); // Thử kết nối lại nếu channel null
      }
    }
  }

  void markAllAsRead() {
    _notifications = _notifications.map((n) => NotificationModel(
      id: n.id,
      category: n.category,
      description: n.description,
      hour: n.hour,
      date: n.date,
      color: n.color,
      read: true,
      data: n.data,
    )).toList();
    _saveNotifications();
  }

  List<NotificationModel> getNotifications() => _notifications;

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute$period';
  }

  String _formatDate(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year.toString().substring(2);
    return '$day/$month/$year';
  }

  Color _getColor(String category) {
    switch (category) {
      case 'Meeting': return Colors.red;
      case 'Performance report': return Colors.green;
      case 'Password change': return Colors.orange;
      case 'Absence request': return Colors.purple;
      case 'Event notification': return Colors.cyan;
      case 'Absence': return Colors.blue;
      case 'Overtime': return Colors.teal;
      case 'payroll': return Colors.yellow;
      default: return Colors.grey;
    }
  }

  void disconnectOnLogout() {
    _isLoggedOut = true; // Đánh dấu đã logout
    _pingTimer?.cancel(); // Dừng ping
    _channel?.sink.close(); // Đóng kết nối WebSocket
    _notificationController.close(); // Đóng stream
    print('Disconnected WebSocket and closed stream on logout');
  }
}