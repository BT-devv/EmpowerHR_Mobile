import 'package:flutter/material.dart';

class NotificationModel {
  final String id;
  final String category;
  final String description;
  final String hour;
  final String date;
  final Color color;
  final bool read;
  final Map<String, dynamic>? data;

  NotificationModel({
    required this.id,
    required this.category,
    required this.description,
    required this.hour,
    required this.date,
    required this.color,
    required this.read,
    this.data,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'description': description,
      'hour': hour,
      'date': date,
      'color': color.value,
      'read': read,
      'data': data,
    };
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'].toString(),
      category: json['category'],
      description: json['description'],
      hour: json['hour'],
      date: json['date'],
      color: Color(json['color']),
      read: json['read'] ?? false,
      data: json['data'],
    );
  }
}