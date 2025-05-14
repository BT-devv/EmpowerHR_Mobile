import 'dart:io';

import 'package:empowerhr_moblie/data/models/user_model.dart';
import 'package:empowerhr_moblie/data/service/api_service.dart';
import 'package:empowerhr_moblie/domain/usecases/update_user_usecase.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:empowerhr_moblie/presentation/bloc/update_user/update_user_bloc.dart';
import 'package:empowerhr_moblie/presentation/bloc/update_user/update_user_event.dart';
import 'package:empowerhr_moblie/presentation/bloc/update_user/update_user_state.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Thêm thư viện để kiểm tra quyền

class PersonalInformationPage extends StatefulWidget {
  final UserModel? user;
  const PersonalInformationPage({super.key, this.user});

  @override
  _PersonalInformationPageState createState() =>
      _PersonalInformationPageState();
}

class _PersonalInformationPageState extends State<PersonalInformationPage> {
  final List<FocusNode> _focusNodes = [];
  bool _isButtonVisible = false;
  final List<bool> _isFocusedList = [];

  bool _isEditablePersonal = false;
  bool _isEditableContact = false;

  // Thêm biến để kiểm soát ẩn/hiện Card Number
  bool _isCardNumberObscured = true;

  // Khởi tạo các TextEditingController cho từng TextField
  late TextEditingController _firstNameController;
  late TextEditingController _middleNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _aliasController;
  late TextEditingController _dobController;
  late TextEditingController _genderController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _personalEmailController;
  late TextEditingController _workEmailController;
  late TextEditingController _addressController;
  late TextEditingController _provinceController;
  late TextEditingController _cityController;
  late TextEditingController _postcodeController;
  late TextEditingController _ownerNameController;
  late TextEditingController _cardNumberController;
  late TextEditingController _bankNameController;
  late TextEditingController _accountNumberController;
  late TextEditingController _employeeTypeController;
  late TextEditingController _departmentController;
  late TextEditingController _positionController;
  late TextEditingController _roleController;
  late TextEditingController _startDateController;
  late TextEditingController _endDateController;

  final ImagePicker _picker = ImagePicker();
  File? _selectedImage; 

  @override
  void initState() {
    super.initState();

    _focusNodes.addAll(List.generate(23, (index) => FocusNode()));
    _isFocusedList.addAll(List.generate(23, (index) => false));

    for (int i = 0; i < _focusNodes.length; i++) {
      final node = _focusNodes[i];
      node.addListener(() {
        setState(() {
          _isFocusedList[i] = node.hasFocus;
          _isButtonVisible = _focusNodes.any((node) => node.hasFocus);
        });
      });
    }

    _firstNameController =
        TextEditingController(text: widget.user?.firstName ?? '');
    _middleNameController = TextEditingController(text: "None");
    _lastNameController =
        TextEditingController(text: widget.user?.lastName ?? '');
    _aliasController = TextEditingController(text: widget.user?.alias ?? '');
    _dobController = TextEditingController(
        text: widget.user?.dateOfBirth?.toIso8601String().split('T')[0] ?? '');
    _genderController = TextEditingController(text: widget.user?.gender ?? '');
    _phoneNumberController =
        TextEditingController(text: widget.user?.phoneNumber ?? '');
    _personalEmailController =
        TextEditingController(text: widget.user?.emailPersonal ?? '');
    _workEmailController =
        TextEditingController(text: widget.user?.emailCompany ?? '');
    _addressController =
        TextEditingController(text: widget.user?.address ?? '');
    _provinceController =
        TextEditingController(text: widget.user?.province ?? '');
    _cityController = TextEditingController(text: widget.user?.city ?? '');
    _postcodeController =
        TextEditingController(text: widget.user?.postcode ?? '');
    _ownerNameController =
        TextEditingController(text: widget.user?.bankAccountName ?? '');
    _cardNumberController =
        TextEditingController(text: widget.user?.bankAccountNumber ?? '');
    _bankNameController = TextEditingController(text: "None");
    _accountNumberController = TextEditingController(text: "None");
    _employeeTypeController =
        TextEditingController(text: widget.user?.employeeType ?? '');
    _departmentController =
        TextEditingController(text: widget.user?.department ?? '');
    _positionController =
        TextEditingController(text: widget.user?.jobTitle ?? '');
    _roleController = TextEditingController(text: widget.user?.role ?? '');
    _startDateController = TextEditingController(
        text: widget.user?.joiningDate?.toIso8601String().split('T')[0] ?? '');
    _endDateController = TextEditingController(text: "N/A");
  }

  @override
  void dispose() {
    for (var node in _focusNodes) {
      node.dispose();
    }

    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _aliasController.dispose();
    _dobController.dispose();
    _genderController.dispose();
    _phoneNumberController.dispose();
    _personalEmailController.dispose();
    _workEmailController.dispose();
    _addressController.dispose();
    _provinceController.dispose();
    _cityController.dispose();
    _postcodeController.dispose();
    _ownerNameController.dispose();
    _cardNumberController.dispose();
    _bankNameController.dispose();
    _accountNumberController.dispose();
    _employeeTypeController.dispose();
    _departmentController.dispose();
    _positionController.dispose();
    _roleController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();

    super.dispose();
  }

  void _handleSave(BuildContext context) async {
    if (widget.user == null || widget.user!.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Không thể cập nhật: Người dùng không tồn tại')),
      );
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final updatedData = {
      'firstName': _firstNameController.text,
      'lastName': _lastNameController.text,
      'dateOfBirth': _dobController.text.isNotEmpty
          ? DateTime.parse(_dobController.text).toIso8601String()
          : null,
      'gender': _genderController.text,
      'phoneNumber': _phoneNumberController.text,
      'email': _personalEmailController.text,
      'bankAccountNumber': _cardNumberController.text.isNotEmpty
          ? _cardNumberController.text
          : null,
      'address': _addressController.text,
      'province': _provinceController.text,
      'city': _cityController.text,
      'postcode': _postcodeController.text,
    };

    context.read<UpdateUserBloc>().add(UpdateUserRequested(
          userId: widget.user!.id!,
          updatedData: updatedData,
          token: token!,
        ));
  }

  Future<void> _openCamera(BuildContext context) async {
    PermissionStatus cameraStatus = await Permission.camera.status;

    if (cameraStatus.isGranted) {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        print("Đường dẫn ảnh từ camera: ${image.path}");
      }
    } else if (cameraStatus.isDenied || cameraStatus.isPermanentlyDenied) {
      PermissionStatus newStatus = await Permission.camera.request();
      if (newStatus.isGranted) {
        final XFile? image =
            await _picker.pickImage(source: ImageSource.camera);
        if (image != null) {
          print("Đường dẫn ảnh từ camera: ${image.path}");
        }
      } else {
        _showPermissionDeniedDialog(context, "camera");
      }
    }
  }

  Future<void> _openGallery(BuildContext context) async {
    PermissionStatus photosStatus = await Permission.photos.status;

    if (photosStatus.isGranted) {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        print("Đường dẫn ảnh từ thư viện: ${image.path}");
      }
    } else if (photosStatus.isDenied || photosStatus.isPermanentlyDenied) {
      PermissionStatus newStatus = await Permission.photos.request();
      if (newStatus.isGranted) {
        final XFile? image =
            await _picker.pickImage(source: ImageSource.gallery);
        if (image != null) {
          print("Đường dẫn ảnh từ thư viện: ${image.path}");
        }
      } else {
        _showPermissionDeniedDialog(context, "photos");
      }
    }
  }

  void _showPermissionDeniedDialog(
      BuildContext context, String permissionType) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Quyền bị từ chối"),
          content: Text(
            permissionType == "camera"
                ? "Ứng dụng cần quyền truy cập camera để chụp ảnh. Vui lòng cấp quyền trong cài đặt."
                : "Ứng dụng cần quyền truy cập thư viện ảnh để chọn ảnh. Vui lòng cấp quyền trong cài đặt.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Hủy"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await openAppSettings();
              },
              child: const Text("Mở cài đặt"),
            ),
          ],
        );
      },
    );
  }

  void _showImageSourceOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      builder: (BuildContext context) {
        return Container(
          height: 280, // Chiều cao cố định
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/bacgroundPopup.png"), // Ảnh từ assets
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 15),
                child: Text(
                  '',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context); // Đóng bottom sheet
                      _openCamera(context); // Mở camera
                    },
                    child: Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset('assets/camera.png'),
                          const SizedBox(height: 10),
                          Text(
                            "Take a picture",
                            style: GoogleFonts.baloo2(
                              textStyle: const TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                            textAlign: TextAlign.center,
                          )
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context); // Đóng bottom sheet
                      _openGallery(context); // Mở thư viện ảnh
                    },
                    child: Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 20),
                          Image.asset('assets/photo.png'),
                          const SizedBox(height: 10),
                          Text(
                            "Choose photo from library",
                            style: GoogleFonts.baloo2(
                              textStyle: const TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    ).catchError((error) {
      print("Error showing bottom sheet: $error"); // Debug log
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi hiển thị tùy chọn: $error')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return BlocProvider(
      create: (context) => UpdateUserBloc(UpdateUserUsecase(ApiService())),
      child: BlocConsumer<UpdateUserBloc, UpdateUserState>(
        listener: (context, state) {
          if (state is UpdateUserSuccess) {
            setState(() {
              _firstNameController.text = state.updatedUser.firstName ?? '';
              _lastNameController.text = state.updatedUser.lastName ?? '';
              _dobController.text = state.updatedUser.dateOfBirth
                      ?.toIso8601String()
                      .split('T')[0] ??
                  '';
              _genderController.text = state.updatedUser.gender ?? '';
              _phoneNumberController.text = state.updatedUser.phoneNumber ?? '';
              _personalEmailController.text =
                  state.updatedUser.emailPersonal ?? '';
              _cardNumberController.text =
                  state.updatedUser.bankAccountNumber ?? '';
              _addressController.text = state.updatedUser.address ?? '';
              _provinceController.text = state.updatedUser.province ?? '';
              _cityController.text = state.updatedUser.city ?? '';
              _postcodeController.text = state.updatedUser.postcode ?? '';
            });

            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Thành công'),
                content: const Text('Cập nhật thông tin thành công!'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      setState(() {
                        _isButtonVisible = false;
                        _isEditablePersonal = false;
                        _isEditableContact = false;
                      });
                      FocusManager.instance.primaryFocus?.unfocus();
                    },
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          } else if (state is UpdateUserFailure) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Lỗi'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(state.error),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              Scaffold(
                backgroundColor: Colors.white,
                body: Stack(
                  children: [
                    SingleChildScrollView(
                      child: Column(
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                height: 223,
                                width: double.infinity,
                                decoration: const BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage(
                                        'assets/background_account.png'),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: MediaQuery.of(context).padding.top + 16,
                                left: 16,
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: const Color.fromRGBO(
                                          255, 255, 255, 1),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Image.asset('assets/chevron-left.png'),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Back',
                                          style: GoogleFonts.baloo2(
                                            textStyle: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.black,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(
                                  top: 223 - (200 / 3),
                                  left: (screenWidth - 200) / 2,
                                ),
                                child: Stack(
                                  children: [
                                    Container(
                                      height: 200,
                                      width: 200,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white,
                                        border: Border.all(
                                          color: Colors.black,
                                          width: 2,
                                        ),
                                        image: const DecorationImage(
                                          image: AssetImage(
                                                  'assets/avata.png')
                                              as ImageProvider,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  //   Positioned(
                                  //       bottom: 10,
                                  //       right: 10,
                                  //       child: GestureDetector(
                                  //         behavior: HitTestBehavior.opaque,
                                  //         onTap: () {
                                  //           print(
                                  //               "Camera icon tapped"); // Debug log
                                  //           _showImageSourceOptions(context);
                                  //         },
                                  //         child: Container(
                                  //           height: 40,
                                  //           width: 40,
                                  //           decoration: BoxDecoration(
                                  //             shape: BoxShape.circle,
                                  //             color: Colors.white,
                                  //             border: Border.all(
                                  //               color: Colors.black,
                                  //               width: 2,
                                  //             ),
                                  //           ),
                                  //           child: const Icon(
                                  //             Icons.camera_alt,
                                  //             size: 24,
                                  //             color: Colors.black,
                                  //           ),
                                  //         ),
                                  //       )),
                                   ],
                                ),
                              ),
                            ],
                          ),
                          Text(
                            widget.user != null
                                ? "${widget.user!.firstName} ${widget.user!.lastName}"
                                : "UnKnow",
                            style: GoogleFonts.baloo2(
                              textStyle: const TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "ID:",
                                style: GoogleFonts.baloo2(
                                  textStyle: const TextStyle(
                                      fontSize: 20,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Text(
                                widget.user?.employeeID ?? "990009923",
                                style: GoogleFonts.baloo2(
                                  textStyle: const TextStyle(
                                      fontSize: 20,
                                      color: Color(0xFF2EB67D),
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          // Personal Information Section
                          Padding(
                            padding: const EdgeInsets.only(left: 16, right: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "PERSONAL INFORMATION",
                                  style: GoogleFonts.baloo2(
                                    textStyle: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _isEditablePersonal = true;
                                    });
                                  },
                                  child: Image.asset(
                                    'assets/edit_info.png',
                                    height: 20,
                                    width: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.only(left: 25, right: 0),
                                  child: _buildTextField(
                                      "First Name",
                                      _firstNameController,
                                      _isEditablePersonal,
                                      _focusNodes[0],
                                      0),
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.only(left: 0, right: 25),
                                  child: _buildTextField(
                                      "Middle Name",
                                      _middleNameController,
                                      _isEditablePersonal,
                                      _focusNodes[1],
                                      1),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.only(left: 25, right: 0),
                                  child: _buildTextField(
                                      "Last Name",
                                      _lastNameController,
                                      _isEditablePersonal,
                                      _focusNodes[2],
                                      2),
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.only(left: 0, right: 25),
                                  child: _buildTextField(
                                      "Alias",
                                      _aliasController,
                                      _isEditablePersonal,
                                      _focusNodes[3],
                                      3),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.only(left: 25, right: 0),
                                  child: _buildTextField(
                                      "D.O.B",
                                      _dobController,
                                      _isEditablePersonal,
                                      _focusNodes[4],
                                      4),
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.only(left: 0, right: 25),
                                  child: _buildTextField(
                                      "Gender",
                                      _genderController,
                                      _isEditablePersonal,
                                      _focusNodes[5],
                                      5),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          // Contact Detail Section
                          Padding(
                            padding: const EdgeInsets.only(left: 16, right: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "CONTACT DETAIL",
                                  style: GoogleFonts.baloo2(
                                    textStyle: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _isEditableContact = true;
                                    });
                                  },
                                  child: Image.asset(
                                    'assets/edit_info.png',
                                    height: 20,
                                    width: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.only(left: 25, right: 25),
                            child: _buildTextField(
                                "Phone Number",
                                _phoneNumberController,
                                _isEditableContact,
                                _focusNodes[6],
                                6),
                          ),
                          const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.only(left: 25, right: 25),
                            child: _buildTextField(
                                "Personal Email",
                                _personalEmailController,
                                _isEditableContact,
                                _focusNodes[7],
                                7),
                          ),
                          const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.only(left: 25, right: 25),
                            child: _buildTextField("Work Email",
                                _workEmailController, false, _focusNodes[8], 8),
                          ),
                          const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.only(left: 25, right: 25),
                            child: _buildTextField(
                                "Address",
                                _addressController,
                                _isEditableContact,
                                _focusNodes[9],
                                9),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.only(left: 25, right: 0),
                                  child: _buildTextField(
                                      "Province",
                                      _provinceController,
                                      _isEditableContact,
                                      _focusNodes[10],
                                      10),
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.only(left: 0, right: 25),
                                  child: _buildTextField(
                                      "City",
                                      _cityController,
                                      _isEditableContact,
                                      _focusNodes[11],
                                      11),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.only(left: 25, right: 25),
                            child: _buildTextField(
                                "Postcode",
                                _postcodeController,
                                _isEditableContact,
                                _focusNodes[12],
                                12),
                          ),
                          const SizedBox(height: 20),
                          // Bank Account Information Section
                          Padding(
                            padding: const EdgeInsets.only(left: 16, right: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "BANK ACCOUNT INFORMATION",
                                  style: GoogleFonts.baloo2(
                                    textStyle: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.only(left: 25, right: 25),
                            child: _buildTextField(
                                "Owner Name",
                                _ownerNameController,
                                false,
                                _focusNodes[13],
                                13),
                          ),
                          const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.only(left: 25, right: 25),
                            child: _buildTextField(
                                "Card Number",
                                _accountNumberController,
                                false,
                                _focusNodes[14],
                                14),
                          ),
                          const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.only(left: 25, right: 25),
                            child: _buildTextField(
                                "Bank Name",
                                _bankNameController,
                                false,
                                _focusNodes[15],
                                15),
                          ),
                          const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.only(left: 25, right: 25),
                            child: _buildTextField(
                                "Account Number",
                                _cardNumberController,
                                false,
                                _focusNodes[16],
                                16,
                                Icons.remove_red_eye, () {
                              setState(() {
                                _isCardNumberObscured = !_isCardNumberObscured;
                              });
                            }),
                          ),
                          const SizedBox(height: 20),
                          // Employee's Access Section
                          Padding(
                            padding: const EdgeInsets.only(left: 16, right: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "EMPLOYEE'S ACCESS",
                                  style: GoogleFonts.baloo2(
                                    textStyle: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.only(left: 25, right: 25),
                            child: _buildTextField(
                                "Employee Type",
                                _employeeTypeController,
                                false,
                                _focusNodes[17],
                                17),
                          ),
                          const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.only(left: 25, right: 25),
                            child: _buildTextField(
                                "Department",
                                _departmentController,
                                false,
                                _focusNodes[18],
                                18),
                          ),
                          const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.only(left: 25, right: 25),
                            child: _buildTextField(
                                "Position",
                                _positionController,
                                false,
                                _focusNodes[19],
                                19),
                          ),
                          const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.only(left: 25, right: 25),
                            child: _buildTextField("Role", _roleController,
                                false, _focusNodes[20], 20),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.only(left: 25, right: 0),
                                  child: _buildTextField(
                                      "Start Date",
                                      _startDateController,
                                      false,
                                      _focusNodes[21],
                                      21),
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.only(left: 0, right: 25),
                                  child: _buildTextField(
                                      "End Date",
                                      _endDateController,
                                      false,
                                      _focusNodes[22],
                                      22),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 20,
                      child: AnimatedOpacity(
                        opacity: _isButtonVisible ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 300),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: ElevatedButton(
                            onPressed: state is UpdateUserLoading
                                ? null
                                : () {
                                    print("Save button pressed");
                                    _handleSave(context);
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2EB67D),
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              state is UpdateUserLoading ? "Saving..." : "Save",
                              style: GoogleFonts.baloo2(
                                textStyle: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (state is UpdateUserLoading)
                Container(
                  color: Colors.black.withOpacity(0.5),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      bool isEditable, FocusNode focusNode, int focusIndex,
      [IconData? suffixIcon, VoidCallback? onSuffixIconTap]) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.baloo2(
            textStyle: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
        ),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: isEditable ? Colors.white : Colors.grey[300],
            border: Border.all(
              color: _isFocusedList[focusIndex] && isEditable
                  ? const Color(0xFF2EB67D)
                  : Colors.grey[300]!,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  enabled: isEditable ||
                      (label == "Account Number" && !_isCardNumberObscured),
                  focusNode: focusNode,
                  obscureText:
                      label == "Account Number" && _isCardNumberObscured,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: '',
                  ),
                  style: GoogleFonts.baloo2(
                    textStyle: const TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              if (suffixIcon != null)
                GestureDetector(
                  onTap: onSuffixIconTap,
                  child: Icon(
                    suffixIcon,
                    color: Colors.grey,
                    size: 20,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
