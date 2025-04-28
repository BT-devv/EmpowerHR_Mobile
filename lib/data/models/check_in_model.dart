class CheckInResponse {
  final bool success;
  final String? message;
  final CheckInData? data;

  CheckInResponse({
    required this.success,
    this.message,
    this.data,
  });

  factory CheckInResponse.fromJson(Map<String, dynamic> json) {
    return CheckInResponse(
      success: json['success'] ?? false,
      message: json['message'],
      data: json['data'] != null ? CheckInData.fromJson(json['data']) : null,
    );
  }
}

class CheckInData {
  final String employeeID;
  final String name;
  final DateTime date;
  final String checkIn;
  final String status;
  final String breakingHours;
  final String workingHours;
  final String timeOff;
  final String id;

  CheckInData({
    required this.employeeID,
    required this.name,
    required this.date,
    required this.checkIn,
    required this.status,
    required this.breakingHours,
    required this.workingHours,
    required this.timeOff,
    required this.id,
  });

  factory CheckInData.fromJson(Map<String, dynamic> json) {
    return CheckInData(
      employeeID: json['employeeID'] ?? '',
      name: json['name'] ?? '',
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      checkIn: json['checkIn'] ?? '',
      status: json['status'] ?? '',
      breakingHours: json['breakingHours'] ?? '',
      workingHours: json['workingHours'] ?? '',
      timeOff: json['timeOff'] ?? '',
      id: json['_id'] ?? '',
    );
  }
}