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

  // Biến mới cho Half-day, Full-day và Leaving period
  String? _halfDayShift; // Lưu giá trị dropdown: "Buổi sáng" hoặc "Buổi tối"
  final TextEditingController _dateController =
      TextEditingController(); // Controller cho ngày (dùng chung)
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _fromHourController = TextEditingController();
  final TextEditingController _fromMinuteController = TextEditingController();
  final TextEditingController _toHourController = TextEditingController();
  final TextEditingController _toMinuteController = TextEditingController();

  bool _shouldShowDateFields() => _absenceType == 'Leaving period';

  // Hàm hiển thị SnackBar thống nhất
  void _showSnackBar(String message, {bool isSuccess = true}) {
    double screenHeight = MediaQuery.of(context).size.height;
    double widgetHeight = 100; // Giả sử chiều cao widget
    double bottomMargin = (screenHeight - widgetHeight) / 2;
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
        margin:
            EdgeInsets.only(top: 5, left: 5, right: 5, bottom: bottomMargin),
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

  // Hàm kiểm tra tính hợp lệ của giờ và phút
  bool _isValidTime(String hour, String minute) {
    if (hour.isEmpty || minute.isEmpty) return false;
    final intHour = int.tryParse(hour);
    final intMinute = int.tryParse(minute);
    if (intHour == null || intMinute == null) return false;
    return intHour >= 0 && intHour <= 23 && intMinute >= 0 && intMinute <= 59;
  }

  // Hàm so sánh thời gian khi cùng ngày
  bool _isTimeValidOnSameDay(
      String fromHour, String fromMinute, String toHour, String toMinute) {
    final intFromHour = int.parse(fromHour);
    final intFromMinute = int.parse(fromMinute);
    final intToHour = int.parse(toHour);
    final intToMinute = int.parse(toMinute);

    // So sánh giờ
    if (intFromHour > intToHour) return false;
    if (intFromHour == intToHour && intFromMinute >= intToMinute) return false;
    return true;
  }

  Future<void> _submitRequest() async {
    if (_isSubmitting) return; // Ngăn nhấn SUBMIT nhiều lần
    String displayType = _absenceType;
    if (_absenceType == 'Half Day') {
      displayType = 'Half Day (${_halfDayShift ?? ''})';
    } else if (_absenceType == 'Leaving period') {
      displayType = 'Leaving Period';
    } else {
      displayType = 'Full Day';
    }

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

    // Validate thêm cho Half-day, Full-day và Leaving period
    if (_absenceType == 'Half Day' && _halfDayShift == null) {
      _showSnackBar('Vui lòng chọn buổi nghỉ (sáng/tối)', isSuccess: false);
      return;
    }
    if (_dateController.text.isEmpty) {
      _showSnackBar('Vui lòng chọn ngày', isSuccess: false);
      return;
    }

    // Chuẩn bị dữ liệu ngày giờ
    String dateFrom;
    String dateTo;
    final selectedDate = _dateController.text;

    // Ánh xạ giá trị type để backend chấp nhận
    String requestType = _absenceType;
    if (_absenceType == 'Leaving period') {
      requestType =
          'Half Day'; // Ánh xạ "Leaving period" thành "Half Day" để backend chấp nhận
    }

    if (_shouldShowDateFields()) {
      // Leaving Period
      if (selectedDate.isEmpty) {
        _showSnackBar('Vui lòng chọn ngày', isSuccess: false);
        return;
      }

      // Kiểm tra các trường giờ và phút
      if (_fromHourController.text.isEmpty ||
          _fromMinuteController.text.isEmpty ||
          _toHourController.text.isEmpty ||
          _toMinuteController.text.isEmpty) {
        _showSnackBar('Vui lòng nhập đầy đủ giờ và phút', isSuccess: false);
        return;
      }

      // Kiểm tra tính hợp lệ của giờ và phút
      if (!_isValidTime(_fromHourController.text, _fromMinuteController.text) ||
          !_isValidTime(_toHourController.text, _toMinuteController.text)) {
        _showSnackBar('Giờ hoặc phút không hợp lệ', isSuccess: false);
        return;
      }

      // Kiểm tra thời gian (giờ quay lại phải lớn hơn giờ rời)
      if (!_isTimeValidOnSameDay(
          _fromHourController.text,
          _fromMinuteController.text,
          _toHourController.text,
          _toMinuteController.text)) {
        _showSnackBar('Giờ quay lại phải lớn hơn giờ rời', isSuccess: false);
        return;
      }

      // Chuẩn bị dữ liệu giờ (giống định dạng Half Day)
      dateFrom =
          '$selectedDate ${_fromHourController.text.padLeft(2, '0')}:${_fromMinuteController.text.padLeft(2, '0')}:00';
      dateTo =
          '$selectedDate ${_toHourController.text.padLeft(2, '0')}:${_toMinuteController.text.padLeft(2, '0')}:00';
    } else if (_absenceType == 'Half Day') {
      // Half Day: Dùng ngày hiện tại, thêm giờ dựa trên _halfDayShift
      dateFrom = selectedDate;
      dateTo = selectedDate;
      if (_halfDayShift == 'Buổi sáng') {
        dateFrom = '$dateFrom 08:00:00'; // Giả sử buổi sáng từ 8h
        dateTo = '$dateTo 12:00:00';
      } else {
        dateFrom = '$dateFrom 13:00:00'; // Giả sử buổi tối từ 13h
        dateTo = '$dateTo 17:00:00';
      }
    } else {
      // Full Day: Dùng ngày từ _dateController
      dateFrom = selectedDate;
      dateTo = selectedDate;
    }

    // Gọi API chung cho tất cả loại yêu cầu
    setState(() => _isSubmitting = true);
    try {
      final result = await AbsenceRequest(
        employeeID: employeeID,
        type: requestType, // Sử dụng giá trị type đã ánh xạ
        dateFrom: dateFrom,
        dateTo: dateTo,
        lineManagers: _selectedManager!.id,
        coworkers: _selectedCoworker?.id ?? '',
        reason: _reasonController.text,
      );
      final successMessage =
          'Yêu cầu xin nghỉ $displayType vào ngày ${dateFrom.split(' ')[0]} thành công!';
      // Xử lý kết quả
      if (result is Map<String, dynamic> && result['success'] == true) {
        _showSnackBar(successMessage, isSuccess: true);
        setState(() {
          _absenceType = 'Half-day absence';
          _selectedManager = null;
          _selectedCoworker = null;
          _halfDayShift = null;
          _dateController.clear();
          _reasonController.clear();
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

  // Widget: Dropdown cho Half-day
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
            final containerWidth = constraints.maxWidth - 40;
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
                  offset: const Offset(0, 45),
                  constraints: BoxConstraints(
                    minWidth: containerWidth,
                    maxWidth: containerWidth,
                  ),
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

  // Widget: Thanh chọn ngày (dùng chung cho Half-day, Full-day và Leaving period)
  Widget _buildDatePicker() {
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
              controller: _dateController,
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
                        dialogBackgroundColor: Colors.white,
                        colorScheme: const ColorScheme.light(
                          primary: Color(0xFF2EB67D),
                          onPrimary: Colors.white,
                          surface: Colors.white,
                          onSurface: Colors.black,
                        ),
                        textButtonTheme: TextButtonThemeData(
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF2EB67D),
                          ),
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (pickedDate != null) {
                  setState(() {
                    _dateController.text =
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
                // Thêm Dropdown cho Half-day và Date Picker cho tất cả
                if (_absenceType == 'Half Day') _buildHalfDayDropdown(),
                _buildDatePicker(),
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
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
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
                        Text(
                          ':',
                          style: GoogleFonts.baloo2(
                            textStyle: const TextStyle(
                              fontSize: 20,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
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
                        Text(
                          'To:',
                          style: GoogleFonts.baloo2(
                            textStyle: const TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
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
                        Text(
                          ':',
                          style: GoogleFonts.baloo2(
                            textStyle: const TextStyle(
                              fontSize: 20,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
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
    _dateController.dispose();
    _reasonController.dispose();
    _fromHourController.dispose();
    _fromMinuteController.dispose();
    _toHourController.dispose();
    _toMinuteController.dispose();
    super.dispose();
  }
}
