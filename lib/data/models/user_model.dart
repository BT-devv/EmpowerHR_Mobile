class UserModel {
  final String id;
  final String? avatar;
  final String firstName;
  final String lastName;
  final String? alias;
  final String? gender;
  final DateTime? dateOfBirth;
  final String? idCardNumber;
  final String? phoneNumber;
  final String emailCompany;
  final String? emailPersonal;
  final String? password;
  final String? address;
  final String? province;
  final String? city;
  final String? postcode;
  final String? bankAccountNumber;
  final String? bankAccountName;
  final String? employeeType;
  final String? department;
  final String? jobTitle;
  final String? role;
  final DateTime? joiningDate;
  final String? status;
  final DateTime? startDate;
  final String? employeeID;

  UserModel({
    required this.id,
    this.avatar,
    required this.firstName,
    required this.lastName,
    this.alias,
    this.gender,
    this.dateOfBirth,
    this.idCardNumber,
    this.phoneNumber,
    required this.emailCompany,
    this.emailPersonal,
    this.password,
    this.address,
    this.province,
    this.city,
    this.postcode,
    this.bankAccountNumber,
    this.bankAccountName,
    this.employeeType,
    this.department,
    this.jobTitle,
    this.role,
    this.joiningDate,
    this.status,
    this.startDate,
    this.employeeID,
  });

  // Factory method để khởi tạo từ JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] as String,
      avatar: json['avatar'] as String?,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      alias: json['alias'] as String?,
      gender: json['gender'] as String?,
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'] as String)
          : null,
      idCardNumber: json['idCardNumber'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      emailCompany: json['emailCompany'] as String,
      emailPersonal: json['emailPersonal'] as String?,
      password: json['password'] as String?,
      address: json['address'] as String?,
      province: json['province'] as String?,
      city: json['city'] as String?,
      postcode: json['postcode'] as String?,
      bankAccountNumber: json['bankAccountNumber'] as String?,
      bankAccountName: json['bankAccountName'] as String?,
      employeeType: json['employeeType'] as String?,
      department: json['department'] as String?,
      jobTitle: json['jobTitle'] as String?,
      role: json['role'] as String?,
      joiningDate: json['joiningDate'] != null
          ? DateTime.parse(json['joiningDate'] as String)
          : null,
      status: json['status'] as String?,
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'] as String)
          : null,
      employeeID: json['employeeID'] as String?,
    );
  }

  // Method để chuyển đối tượng thành JSON (khi cần gửi lên API)
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'avatar': avatar,
      'firstName': firstName,
      'lastName': lastName,
      'alias': alias,
      'gender': gender,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'idCardNumber': idCardNumber,
      'phoneNumber': phoneNumber,
      'emailCompany': emailCompany,
      'emailPersonal': emailPersonal,
      'password': password,
      'address': address,
      'province': province,
      'city': city,
      'postcode': postcode,
      'bankAccountNumber': bankAccountNumber,
      'bankAccountName': bankAccountName,
      'employeeType': employeeType,
      'department': department,
      'jobTitle': jobTitle,
      'role': role,
      'joiningDate': joiningDate?.toIso8601String(),
      'status': status,
      'startDate': startDate?.toIso8601String(),
      'employeeID': employeeID,
    };
  }
}
