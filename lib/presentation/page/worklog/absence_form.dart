import 'package:empowerhr_moblie/domain/usecases/absence_request_usecase.dart';
import 'package:empowerhr_moblie/domain/usecases/get_user_by_role.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:empowerhr_moblie/data/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AbsenceRequestForm extends StatefulWidget {
  const AbsenceRequestForm({super.key});

  @override
  _AbsenceRequestFormState createState() => _AbsenceRequestFormState();
}

class _AbsenceRequestFormState extends State<AbsenceRequestForm> {
  String _absenceType = 'Half-day absence';
  List<UserModel> _managers = [];
  UserModel? _selectedManager;
  bool _isLoadingManagers = false;
  List<UserModel> _coworkers = [];
  UserModel? _selectedCoworker;
  bool _isLoadingCoworkers = false;
  bool _isSubmitting = false;

  // Biến mới cho Half-day và Full-day
  String? _halfDayShift; // Lưu giá trị dropdown: "Buổi sáng" hoặc "Buổi tối"
  final TextEditingController _fullDayDateController =
      TextEditingController(); // Controller cho ngày Full-day

  // Controllers cho các trường nhập liệu
  final TextEditingController _dateFromController = TextEditingController();
  final TextEditingController _dateToController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _fromHourController = TextEditingController();
  final TextEditingController _fromMinuteController = TextEditingController();
  final TextEditingController _toHourController = TextEditingController();
  final TextEditingController _toMinuteController = TextEditingController();

  bool _shouldShowDateFields() => _absenceType == 'Leaving period';

  // Hàm hiển thị SnackBar thống nhất
  void _showSnackBar(String message, {bool isSuccess = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle : Icons.cancel,
              color: isSuccess ? const Color(0xFF2EB67D) : Colors.red,
              size: 24,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.baloo2(
                  textStyle: const TextStyle(fontSize: 16, color: Colors.black),
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(top: 5, left: 5, right: 5, bottom: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: isSuccess ? const Color(0xFF2EB67D) : Colors.red,
            width: 2,
          ),
        ),
        elevation: 6,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _fetchManagers() async {
    setState(() => _isLoadingManagers = true);
    try {
      _managers = await getUsersByRole("67fc24eb88df30b9541815ec");
      setState(() => _isLoadingManagers = false);
      if (_managers.isNotEmpty) {
        _showUserDialog(
          title: 'Select a Manager',
          users: _managers,
          onUserSelected: (user) => setState(() => _selectedManager = user),
        );
      } else {
        _showSnackBar('No managers found', isSuccess: false);
      }
    } catch (error) {
      setState(() => _isLoadingManagers = false);
      _showSnackBar('Error fetching managers: $error', isSuccess: false);
    }
  }

  Future<void> _fetchCoworkers() async {
    setState(() => _isLoadingCoworkers = true);
    try {
      _coworkers = await getUsersByRole("67fc250288df30b9541815f0");
      setState(() => _isLoadingCoworkers = false);
      if (_coworkers.isNotEmpty) {
        _showUserDialog(
          title: 'Select a Co-worker',
          users: _coworkers,
          onUserSelected: (user) => setState(() => _selectedCoworker = user),
        );
      } else {
        _showSnackBar('No co-workers found', isSuccess: false);
      }
    } catch (error) {
      setState(() => _isLoadingCoworkers = false);
      _showSnackBar('Error fetching co-workers: $error', isSuccess: false);
    }
  }

  void _showUserDialog({
    required String title,
    required List<UserModel> users,
    required void Function(UserModel) onUserSelected,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(title,
            style:
                GoogleFonts.baloo2(fontSize: 18, fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                onTap: () {
                  onUserSelected(user);
                  Navigator.pop(context);
                },
                title: Text(
                  '${user.firstName} ${user.lastName}',
                  style: GoogleFonts.baloo2(fontSize: 16),
                ),
                subtitle: Text(
                  user.emailCompany,
                  style: GoogleFonts.baloo2(fontSize: 14, color: Colors.grey),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: GoogleFonts.baloo2(fontSize: 16, color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  Future<void> _submitRequest() async {
    if (_isSubmitting) return; // Ngăn nhấn SUBMIT nhiều lần

    // Validate input
    final prefs = await SharedPreferences.getInstance();
    final employeeID = prefs.getString('employeeID');
    if (employeeID == null) {
      _showSnackBar('Không tìm thấy thông tin nhân viên', isSuccess: false);
      return;
    }
    if (_absenceType.isEmpty) {
      _showSnackBar('Vui lòng chọn loại nghỉ', isSuccess: false);
      return;
    }
    if (_selectedManager == null) {
      _showSnackBar('Vui lòng chọn Line Manager', isSuccess: false);
      return;
    }
    if (_reasonController.text.isEmpty) {
      _showSnackBar('Vui lòng nhập lý do nghỉ', isSuccess: false);
      return;
    }

    // Validate thêm cho Half-day và Full-day
    if (_absenceType == 'Half Day' && _halfDayShift == null) {
      _showSnackBar('Vui lòng chọn buổi nghỉ (sáng/tối)', isSuccess: false);
      return;
    }
    if (_absenceType == 'Full Day' && _fullDayDateController.text.isEmpty) {
      _showSnackBar('Vui lòng chọn ngày nghỉ', isSuccess: false);
      return;
    }

    // Chuẩn bị dữ liệu ngày giờ
    String dateFrom;
    String dateTo;
    if (_shouldShowDateFields()) {
      // Leaving Period
      dateFrom = _dateFromController.text;
      dateTo = _dateToController.text;
      if (dateFrom.isEmpty || dateTo.isEmpty) {
        _showSnackBar('Vui lòng chọn ngày bắt đầu và kết thúc',
            isSuccess: false);
        return;
      }
      if (_fromHourController.text.isNotEmpty &&
          _fromMinuteController.text.isNotEmpty) {
        dateFrom =
            '$dateFrom ${_fromHourController.text}:${_fromMinuteController.text}:00';
      }
      if (_toHourController.text.isNotEmpty &&
          _toMinuteController.text.isNotEmpty) {
        dateTo =
            '$dateTo ${_toHourController.text}:${_toMinuteController.text}:00';
      }
    } else if (_absenceType == 'Half Day') {
      // Half Day: Dùng ngày hiện tại, thêm giờ dựa trên _halfDayShift
      dateFrom = _fullDayDateController.text;
      dateTo = dateFrom;
      if (_halfDayShift == 'Buổi sáng') {
        dateFrom = '$dateFrom 08:00:00'; // Giả sử buổi sáng từ 8h
        dateTo = '$dateTo 12:00:00';
      } else {
        dateFrom = '$dateFrom 13:00:00'; // Giả sử buổi tối từ 13h
        dateTo = '$dateTo 17:00:00';
      }
    } else {
      // Full Day: Dùng ngày từ _fullDayDateController
      dateFrom = _fullDayDateController.text;
      dateTo = dateFrom;
    }

    // Gọi API với trạng thái loading
    setState(() => _isSubmitting = true);
    try {
      final result = await AbsenceRequest(
        employeeID: employeeID,
        type: _absenceType,
        dateFrom: dateFrom,
        dateTo: dateTo,
        lineManagers: _selectedManager!.id,
        coworkers: _selectedCoworker?.id ?? '',
        reason: _reasonController.text,
      );

      // Xử lý kết quả
      if (result is Map<String, dynamic> && result['success'] == true) {
        _showSnackBar(result['message'] as String, isSuccess: true);
        setState(() {
          _absenceType = 'Half-day absence';
          _selectedManager = null;
          _selectedCoworker = null;
          _halfDayShift = null; // Reset dropdown
          _fullDayDateController.clear(); // Reset ngày Full-day
          _reasonController.clear();
          _dateFromController.clear();
          _dateToController.clear();
          _fromHourController.clear();
          _fromMinuteController.clear();
          _toHourController.clear();
          _toMinuteController.clear();
        });
      } else {
        _showSnackBar(
          result is Map<String, dynamic>
              ? _mapErrorMessage(result['message'] as String)
              : 'Lỗi không xác định từ API',
          isSuccess: false,
        );
      }
    } catch (e) {
      print('Error during API call: $e');
      _showSnackBar('Lỗi khi gửi yêu cầu: $e', isSuccess: false);
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  // Hàm ánh xạ thông báo lỗi
  String _mapErrorMessage(String message) {
    const errorMessages = {
      'Nhân viên không tồn tại': 'Nhân viên không tồn tại.',
      'Không thể gửi yêu cầu nghỉ cho ngày trong quá khứ':
          'Không thể gửi yêu cầu nghỉ cho ngày trong quá khứ.',
      'Ngày kết thúc không thể trước ngày bắt đầu':
          'Ngày kết thúc không thể trước ngày bắt đầu.',
      'Không thể gửi yêu cầu nghỉ vào Thứ 7 hoặc Chủ nhật':
          'Không thể gửi yêu cầu nghỉ vào Thứ 7 hoặc Chủ nhật.',
      'Yêu cầu nghỉ Full Day phải được gửi trước ít nhất 1 ngày':
          'Yêu cầu nghỉ Full Day phải được gửi trước ít nhất 1 ngày.',
      'Bạn đã hết số ngày nghỉ':
          'Bạn đã hết số ngày nghỉ, nghỉ thêm sẽ bị trừ lương!',
    };
    return errorMessages.entries
        .firstWhere(
          (entry) => message.contains(entry.key),
          orElse: () => MapEntry('', message),
        )
        .value;
  }

  Widget _buildReportToLineManager() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Text(
            'Report to a Line Manager',
            style:
                GoogleFonts.baloo2(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            height: 45,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _isLoadingManagers
                      ? const Center(child: CircularProgressIndicator())
                      : Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Text(
                            _selectedManager != null
                                ? '${_selectedManager!.firstName} ${_selectedManager!.lastName}'
                                : 'Select a manager',
                            style: GoogleFonts.baloo2(
                              fontSize: 16,
                              color: _selectedManager != null
                                  ? Colors.black
                                  : Colors.grey,
                            ),
                          ),
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: GestureDetector(
                    onTap: _fetchManagers,
                    child: const Icon(Icons.add, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildAddCoworker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Text(
            'Add a co-worker',
            style:
                GoogleFonts.baloo2(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            height: 45,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _isLoadingCoworkers
                      ? const Center(child: CircularProgressIndicator())
                      : Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Text(
                            _selectedCoworker != null
                                ? '${_selectedCoworker!.firstName} ${_selectedCoworker!.lastName}'
                                : 'Select a co-worker',
                            style: GoogleFonts.baloo2(
                              fontSize: 16,
                              color: _selectedCoworker != null
                                  ? Colors.black
                                  : Colors.grey,
                            ),
                          ),
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: GestureDetector(
                    onTap: _fetchCoworkers,
                    child: const Icon(Icons.add, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  // Widget mới: Dropdown cho Half-day
  Widget _buildHalfDayDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Text(
            'Select Shift',
            style:
                GoogleFonts.baloo2(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            // Lấy chiều rộng của container cha (trừ padding ngang 20px)
            final containerWidth =
                constraints.maxWidth - 40; // Trừ padding 20px mỗi bên
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 45,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: PopupMenuButton<String>(
                  color: Colors.white,
                  onSelected: (value) {
                    setState(() => _halfDayShift = value);
                  },
                  offset: const Offset(
                      0, 45), // Đặt vị trí menu ngay dưới container
                  constraints: BoxConstraints(
                    minWidth: containerWidth,
                    maxWidth: containerWidth,
                  ), // Đặt chiều rộng menu bằng container
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: const BorderSide(color: Colors.black),
                  ),
                  padding: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _halfDayShift ?? 'Select shift (morning/evening)',
                          style: GoogleFonts.baloo2(
                            fontSize: 16,
                            color: _halfDayShift != null
                                ? Colors.black
                                : Colors.grey,
                          ),
                        ),
                        const Icon(Icons.arrow_drop_down, color: Colors.grey),
                      ],
                    ),
                  ),
                  itemBuilder: (context) => [
                    PopupMenuItem<String>(
                      value: 'Buổi sáng',
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          'Buổi sáng',
                          style: GoogleFonts.baloo2(
                              fontSize: 16, color: Colors.black),
                        ),
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'Buổi tối',
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          'Buổi tối',
                          style: GoogleFonts.baloo2(
                              fontSize: 16, color: Colors.black),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  // Widget mới: Thanh chọn ngày cho Full-day
  Widget _buildFullDayDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Text(
            'Select Date',
            style:
                GoogleFonts.baloo2(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            height: 45,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              controller: _fullDayDateController,
              decoration: InputDecoration(
                hintText: 'Select date (YYYY-MM-DD)',
                hintStyle: GoogleFonts.baloo2(fontSize: 16, color: Colors.grey),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.only(left: 10, top: 8),
                suffixIcon: const Icon(Icons.calendar_today,
                    color: Colors.grey, size: 20),
              ),
              style: GoogleFonts.baloo2(fontSize: 16, color: Colors.black),
              readOnly: true,
              onTap: () async {
                final pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        dialogBackgroundColor:
                            Colors.white, // Background màu trắng
                        colorScheme: const ColorScheme.light(
                          primary: Color(0xFF2EB67D), // Màu của ngày được chọn
                          onPrimary:
                              Colors.white, // Màu chữ trên ngày được chọn
                          surface: Colors.white, // Nền của DatePicker
                          onSurface: Colors.black, // Màu chữ (ngày, tháng, năm)
                        ),
                        textButtonTheme: TextButtonThemeData(
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(
                                0xFF2EB67D), // Màu nút "OK", "Cancel"
                          ),
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (pickedDate != null) {
                  setState(() {
                    _fullDayDateController.text =
                        pickedDate.toIso8601String().split('T')[0];
                  });
                }
              },
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Image.asset('assets/absence_form_bg.png'),
                    Positioned(
                      top: MediaQuery.of(context).padding.top + 16,
                      left: 16,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.white,
                          ),
                          child: Row(
                            children: [
                              Image.asset('assets/chevron-left.png'),
                              const SizedBox(width: 4),
                              Text(
                                'Back',
                                style: GoogleFonts.baloo2(
                                    fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20, top: 30),
                  child: Text(
                    'Absence type',
                    style: GoogleFonts.baloo2(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: RadioListTile<String>(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    title: Text('Half-day absence',
                        style: GoogleFonts.baloo2(fontSize: 16)),
                    value: 'Half Day',
                    groupValue: _absenceType,
                    onChanged: (value) => setState(() => _absenceType = value!),
                    activeColor: const Color(0xFF2EB67D),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: RadioListTile<String>(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    title: Text('Full-day absence',
                        style: GoogleFonts.baloo2(fontSize: 16)),
                    value: 'Full Day',
                    groupValue: _absenceType,
                    onChanged: (value) => setState(() => _absenceType = value!),
                    activeColor: const Color(0xFF2EB67D),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: RadioListTile<String>(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    title: Text('Leaving period',
                        style: GoogleFonts.baloo2(fontSize: 16)),
                    value: 'Leaving period',
                    groupValue: _absenceType,
                    onChanged: (value) => setState(() => _absenceType = value!),
                    activeColor: const Color(0xFF2EB67D),
                  ),
                ),
                const SizedBox(height: 20),
                _buildReportToLineManager(),
                _buildAddCoworker(),
                // Thêm Dropdown cho Half-day và Date Picker cho Full-day
                if (_absenceType == 'Half Day') _buildHalfDayDropdown(),
                if (_absenceType == 'Half Day') _buildFullDayDatePicker(),
                if (_absenceType == 'Full Day') _buildFullDayDatePicker(),
                
                if (_shouldShowDateFields()) ...[
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Text(
                      'You will leave from:',
                      style: GoogleFonts.baloo2(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 50,
                          child: TextField(
                            controller: _fromHourController,
                            decoration: InputDecoration(
                              hintText: 'HH',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14)),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          width: 50,
                          child: TextField(
                            controller: _fromMinuteController,
                            decoration: InputDecoration(
                              hintText: 'MM',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14)),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _dateFromController,
                            decoration: InputDecoration(
                              hintText: 'Select date (YYYY-MM-DD)',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              suffixIcon: const Icon(Icons.calendar_today,
                                  color: Colors.grey, size: 20),
                            ),
                            readOnly: true,
                            onTap: () async {
                              final pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime(2100),
                              );
                              if (pickedDate != null) {
                                setState(() {
                                  _dateFromController.text = pickedDate
                                      .toIso8601String()
                                      .split('T')[0];
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Text(
                      'To:',
                      style: GoogleFonts.baloo2(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 50,
                          child: TextField(
                            controller: _toHourController,
                            decoration: InputDecoration(
                              hintText: 'HH',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14)),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          width: 50,
                          child: TextField(
                            controller: _toMinuteController,
                            decoration: InputDecoration(
                              hintText: 'MM',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14)),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _dateToController,
                            decoration: InputDecoration(
                              hintText: 'Select date (YYYY-MM-DD)',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              suffixIcon: const Icon(Icons.calendar_today,
                                  color: Colors.grey, size: 20),
                            ),
                            readOnly: true,
                            onTap: () async {
                              final pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime(2100),
                              );
                              if (pickedDate != null) {
                                setState(() {
                                  _dateToController.text = pickedDate
                                      .toIso8601String()
                                      .split('T')[0];
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Text(
                    'Reason of leaving:',
                    style: GoogleFonts.baloo2(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                    controller: _reasonController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: 'Enter reason',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 15),
                    ),
                    style: GoogleFonts.baloo2(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 60, vertical: 20),
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitRequest,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2EB67D),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'SUBMIT',
                            style: GoogleFonts.baloo2(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
          if (_isSubmitting)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _dateFromController.dispose();
    _dateToController.dispose();
    _reasonController.dispose();
    _fromHourController.dispose();
    _fromMinuteController.dispose();
    _toHourController.dispose();
    _toMinuteController.dispose();
    _fullDayDateController.dispose();
    super.dispose();
  }
}
