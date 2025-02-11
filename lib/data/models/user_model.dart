class UserModel {
  final String userID;
  final String email;
  final String firstName;
  final String? lastName;
  final DateTime? dateOfBirth;
  final bool gender; // true = male, false = female
  final String userType;
  final String expertise;
  final String address;
  final String province;
  final int postcode;
  final bool status;
  final DateTime createAt;
  final DateTime updateAt;

  UserModel({
    required this.userID,
    required this.email,
    required this.firstName,
    this.lastName,
    this.dateOfBirth,
    required this.gender,
    required this.userType,
    required this.expertise,
    required this.address,
    required this.province,
    required this.postcode,
    required this.status,
    required this.createAt,
    required this.updateAt,
  });

  // Factory method để khởi tạo từ JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userID: json['userID'],
      email: json['email'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'])
          : null,
      gender: json['gender'],
      userType: json['userType'],
      expertise: json['expertise'],
      address: json['address'],
      province: json['province'],
      postcode: json['postcode'],
      status: json['status'],
      createAt: DateTime.parse(json['createAt']),
      updateAt: DateTime.parse(json['updateAt']),
    );
  }

  // Method để chuyển đối tượng thành JSON (khi cần gửi lên API)
  Map<String, dynamic> toJson() {
    return {
      'userID': userID,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'gender': gender,
      'userType': userType,
      'expertise': expertise,
      'address': address,
      'province': province,
      'postcode': postcode,
      'status': status,
      'createAt': createAt.toIso8601String(),
      'updateAt': updateAt.toIso8601String(),
    };
  }
}
