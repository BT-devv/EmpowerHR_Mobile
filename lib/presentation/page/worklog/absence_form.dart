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
  String _absenceType = 'Half Day';
  List<UserModel> _managers = [];
  List<UserModel> _selectedManagers = [];
  List<UserModel> _unselectedManagers = [];
  bool _isLoadingManagers = false;
  List<UserModel> _coworkers = [];
  List<UserModel> _selectedCoworkers = [];
  List<UserModel> _unselectedCoworkers = [];
  bool _isLoadingCoworkers = false;
  bool _isSubmitting = false;

  String? _halfDayShift;
  TimeOfDay? _leaveFromTime;
  TimeOfDay? _leaveToTime;
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();

  bool _shouldShowTimeFields() => _absenceType == 'Leave Desk';

  void _showSnackBar(String message, {bool isSuccess = true}) {
    final screenHeight = MediaQuery.of(context).size.height;
    final bottomMargin = (screenHeight - 100) / 2;
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
                child: Text(message,
                    style:
                        GoogleFonts.baloo2(fontSize: 16, color: Colors.black))),
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
              width: 2),
        ),
        elevation: 6,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _fetchUsers(
      String role,
      List<UserModel> users,
      List<UserModel> selected,
      List<UserModel> unselected,
      String title) async {
    setState(() => _isLoadingManagers =
        title == 'Select Managers' ? true : _isLoadingCoworkers);
    try {
      final fetchedUsers = await getUsersByRole(role);
      if (fetchedUsers.isNotEmpty) {
        _showUserDialog(
            title: title,
            users: fetchedUsers,
            selectedUsers: selected,
            unselectedUsers: unselected,
            onConfirm: (sel, unsel) {
              setState(() {
                if (title == 'Select Managers') {
                  _selectedManagers = sel;
                  _unselectedManagers = unsel;
                  _isLoadingManagers = false;
                } else {
                  _selectedCoworkers = sel;
                  _unselectedCoworkers = unsel;
                  _isLoadingCoworkers = false;
                }
              });
            });
      } else {
        _showSnackBar('No $title found', isSuccess: false);
      }
    } catch (error) {
      setState(() {
        if (title == 'Select Managers')
          _isLoadingManagers = false;
        else
          _isLoadingCoworkers = false;
      });
      _showSnackBar('Error fetching $title: $error', isSuccess: false);
    }
  }

  void _showUserDialog({
    required String title,
    required List<UserModel> users,
    required List<UserModel> selectedUsers,
    required List<UserModel> unselectedUsers,
    required void Function(List<UserModel>, List<UserModel>) onConfirm,
  }) {
    List<UserModel> tempSelected = List<UserModel>.from(selectedUsers);
    List<UserModel> tempUnselected = List<UserModel>.from(unselectedUsers);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          title: Text(title,
              style: GoogleFonts.baloo2(
                  fontSize: 18, fontWeight: FontWeight.bold)),
          content: SizedBox(
              width: double.maxFinite,
              height: 300,
              child: ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  final isSelected = tempSelected.contains(user);
                  final isUnselected = tempUnselected.contains(user);
                  return RadioListTile<UserModel>(
                    value: user,
                    groupValue: isSelected ? user : null,
                    onChanged: isUnselected
                        ? null
                        : (UserModel? value) {
                            setDialogState(() {
                              if (isSelected) {
                                tempSelected.remove(user);
                                tempUnselected.add(user);
                              } else if (value != null) {
                                tempSelected.add(value);
                              }
                            });
                          },
                    activeColor: const Color(0xFF2EB67D),
                    title: Text('${user.firstName} ${user.lastName}',
                        style: GoogleFonts.baloo2(fontSize: 16)),
                    subtitle: Text(user.emailCompany,
                        style: GoogleFonts.baloo2(
                            fontSize: 14, color: Colors.grey)),
                  );
                },
              )),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel',
                    style:
                        GoogleFonts.baloo2(fontSize: 16, color: Colors.grey))),
            TextButton(
                onPressed: () {
                  onConfirm(tempSelected, tempUnselected);
                  Navigator.pop(context);
                },
                child: Text('Confirm',
                    style: GoogleFonts.baloo2(
                        fontSize: 16, color: const Color(0xFF2EB67D)))),
          ],
        ),
      ),
    ).then((_) => setState(() {}));
  }

  Future<void> _submitRequest() async {
    if (_isSubmitting) return;
    final displayType = _absenceType == 'Half Day'
        ? 'Half Day (${_halfDayShift ?? ''})'
        : _absenceType == 'Leave Desk'
            ? 'Leave Desk'
            : 'Full Day';
    final prefs = await SharedPreferences.getInstance();
    final employeeID = prefs.getString('employeeID');
    if (employeeID == null)
      return _showSnackBar('Không tìm thấy thông tin nhân viên',
          isSuccess: false);
    if (_absenceType.isEmpty ||
        _selectedManagers.isEmpty ||
        _reasonController.text.isEmpty ||
        _dateController.text.isEmpty) {
      _showSnackBar('Vui lòng điền đầy đủ thông tin', isSuccess: false);
      return;
    }
    if (_absenceType == 'Half Day' && _halfDayShift == null)
      return _showSnackBar('Vui lòng chọn buổi nghỉ (sáng/tối)',
          isSuccess: false);
    if (_absenceType == 'Leave Desk' &&
        (_leaveFromTime == null || _leaveToTime == null)) {
      _showSnackBar('Vui lòng chọn thời gian bắt đầu và kết thúc',
          isSuccess: false);
      return;
    }

    String dateFrom = _dateController.text;
    String dateTo = _dateController.text;
    String? session;
    String? leaveFromTime;
    String? leaveToTime;

    if (_absenceType == 'Half Day') {
      session = _halfDayShift;
      if (_halfDayShift == 'Morning') {
        leaveFromTime = '$dateFrom 08:00:00';
        leaveToTime = '$dateFrom 12:00:00';
      } else if (_halfDayShift == 'Afternoon') {
        leaveFromTime = '$dateFrom 13:00:00';
        leaveToTime = '$dateFrom 17:00:00';
      }
    } else if (_absenceType == 'Leave Desk') {
      final selectedDate = _dateController.text;
      leaveFromTime =
          '$selectedDate ${_leaveFromTime!.hour.toString().padLeft(2, '0')}:${_leaveFromTime!.minute.toString().padLeft(2, '0')}:00';
      leaveToTime =
          '$selectedDate ${_leaveToTime!.hour.toString().padLeft(2, '0')}:${_leaveToTime!.minute.toString().padLeft(2, '0')}:00';
      if (_leaveFromTime!.hour > _leaveToTime!.hour ||
          (_leaveFromTime!.hour == _leaveToTime!.hour &&
              _leaveFromTime!.minute >= _leaveToTime!.minute)) {
        _showSnackBar('Thời gian kết thúc phải sau thời gian bắt đầu',
            isSuccess: false);
        return;
      }
    }

    final lineManagers =
        _selectedManagers.map((user) => user.employeeID).toList();
    final teammates =
        _selectedCoworkers.map((user) => user.employeeID).toList();

    setState(() => _isSubmitting = true);
    try {
      final result = await AbsenceRequest(
        employeeID: employeeID,
        type: _absenceType,
        dateFrom: dateFrom,
        dateTo: dateTo,
        lineManagers: lineManagers.isNotEmpty ? [lineManagers.join(',')] : [''],
        teammates: teammates.isNotEmpty ? [teammates.join(',')] : [''],
        reason: _reasonController.text,
        session: session,
        leaveFromTime: leaveFromTime,
        leaveToTime: leaveToTime,
      );
      if (result['success']) {
        _showSnackBar(
            'Yêu cầu xin nghỉ $displayType vào ngày ${dateFrom} thành công!',
            isSuccess: true);
        setState(() {
          _absenceType = 'Half Day';
          _selectedManagers.clear();
          _unselectedManagers.clear();
          _selectedCoworkers.clear();
          _unselectedCoworkers.clear();
          _halfDayShift = null;
          _leaveFromTime = null;
          _leaveToTime = null;
          _dateController.clear();
          _reasonController.clear();
        });
      } else {
        _showSnackBar(_mapErrorMessage(result['message']), isSuccess: false);
      }
    } catch (e) {
      _showSnackBar('Lỗi khi gửi yêu cầu: $e', isSuccess: false);
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

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
      'Vui lòng chọn buổi (sáng hoặc chiều) cho Half Day':
          'Vui lòng chọn buổi nghỉ (sáng/tối) cho Half Day.',
      'Vui lòng nhập thời gian bắt đầu và kết thúc khi chọn Leave Desk':
          'Vui lòng chọn thời gian bắt đầu và kết thúc cho Leave Desk.',
      'Thời gian kết thúc phải sau thời gian bắt đầu':
          'Thời gian kết thúc phải sau thời gian bắt đầu.',
      'Bạn đã có đơn xin nghỉ phép trong khoảng ngày này':
          'Bạn đã có đơn xin nghỉ phép trong khoảng ngày này.',
      'Ngày nghỉ trùng với ngày nghỉ lễ': 'Ngày nghỉ trùng với ngày nghỉ lễ.',
    };
    return errorMessages.entries
        .firstWhere(
          (entry) => message.contains(entry.key),
          orElse: () => MapEntry('', message),
        )
        .value;
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
              _buildHeader(),
              Padding(
                  padding: const EdgeInsets.only(left: 20, top: 30),
                  child: Text('Absence type',
                      style: GoogleFonts.baloo2(
                          fontSize: 16, fontWeight: FontWeight.bold))),
              _buildAbsenceTypeRadios(),
              const SizedBox(height: 20),
              ReportToLineManager(
                isLoading: _isLoadingManagers,
                selectedManagers: _selectedManagers,
                unselectedManagers: _unselectedManagers,
                onFetch: () => _fetchUsers(
                    "67fc24eb88df30b9541815ec",
                    _managers,
                    _selectedManagers,
                    _unselectedManagers,
                    'Select Managers'),
              ),
              AddCoworker(
                isLoading: _isLoadingCoworkers,
                selectedCoworkers: _selectedCoworkers,
                unselectedCoworkers: _unselectedCoworkers,
                onFetch: () => _fetchUsers(
                    "67fc250288df30b9541815f0",
                    _coworkers,
                    _selectedCoworkers,
                    _unselectedCoworkers,
                    'Select Co-workers'),
              ),
              if (_absenceType == 'Half Day')
                HalfDayDropdown(
                  onSelected: (value) => setState(() => _halfDayShift = value),
                  selectedValue: _halfDayShift,
                ),
              DatePicker(dateController: _dateController),
              if (_shouldShowTimeFields())
                TimePicker(
                  leaveFromTime: _leaveFromTime,
                  leaveToTime: _leaveToTime,
                  onFromTimeSelected: (time) =>
                      setState(() => _leaveFromTime = time),
                  onToTimeSelected: (time) =>
                      setState(() => _leaveToTime = time),
                ),
              Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Text('Reason of leaving:',
                      style: GoogleFonts.baloo2(
                          fontSize: 16, fontWeight: FontWeight.bold))),
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
                  )),
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
                            borderRadius: BorderRadius.circular(8))),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : Text('SUBMIT',
                            style: GoogleFonts.baloo2(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                  )),
            ],
          )),
          if (_isSubmitting)
            Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(child: CircularProgressIndicator())),
        ],
      ),
    );
  }

  Widget _buildHeader() => Stack(
        children: [
          Image.asset('assets/absence_form_bg.png'),
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white),
                child: Row(children: [
                  Image.asset('assets/chevron-left.png'),
                  const SizedBox(width: 4),
                  Text('Back',
                      style: GoogleFonts.baloo2(
                          fontSize: 16, fontWeight: FontWeight.w600))
                ]),
              ),
            ),
          ),
        ],
      );

  Widget _buildAbsenceTypeRadios() => Column(
        children: [
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
              )),
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
              )),
          Padding(
              padding: const EdgeInsets.only(left: 20),
              child: RadioListTile<String>(
                contentPadding: EdgeInsets.zero,
                dense: true,
                title:
                    Text('Leave Desk', style: GoogleFonts.baloo2(fontSize: 16)),
                value: 'Leave Desk',
                groupValue: _absenceType,
                onChanged: (value) => setState(() => _absenceType = value!),
                activeColor: const Color(0xFF2EB67D),
              )),
        ],
      );

  @override
  void dispose() {
    _dateController.dispose();
    _reasonController.dispose();
    super.dispose();
  }
}

class HalfDayDropdown extends StatelessWidget {
  final Function(String) onSelected;
  final String? selectedValue;

  const HalfDayDropdown(
      {super.key, required this.onSelected, this.selectedValue});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final containerWidth = constraints.maxWidth - 40;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Text('Select Shift',
                    style: GoogleFonts.baloo2(
                        fontSize: 16, fontWeight: FontWeight.bold))),
            const SizedBox(height: 10),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  height: 45,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8)),
                  child: PopupMenuButton<String>(
                    color: Colors.white,
                    onSelected: onSelected,
                    offset: const Offset(0, 45),
                    constraints: BoxConstraints(
                        minWidth: containerWidth, maxWidth: containerWidth),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(color: Colors.black)),
                    padding: EdgeInsets.zero,
                    child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              selectedValue ?? 'Select shift (morning/evening)',
                              style: GoogleFonts.baloo2(
                                  fontSize: 16,
                                  color: selectedValue != null
                                      ? Colors.black
                                      : Colors.grey),
                            ),
                            const Icon(Icons.arrow_drop_down,
                                color: Colors.grey),
                          ],
                        )),
                    itemBuilder: (context) => [
                      PopupMenuItem<String>(
                          value: 'Morning',
                          child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Text('Morning',
                                  style: GoogleFonts.baloo2(
                                      fontSize: 16, color: Colors.black)))),
                      PopupMenuItem<String>(
                          value: 'Afternoon',
                          child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Text('Afternoon',
                                  style: GoogleFonts.baloo2(
                                      fontSize: 16, color: Colors.black)))),
                    ],
                  ),
                )),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }
}

class ReportToLineManager extends StatelessWidget {
  final bool isLoading;
  final List<UserModel> selectedManagers;
  final List<UserModel> unselectedManagers;
  final VoidCallback onFetch;

  const ReportToLineManager(
      {super.key,
      required this.isLoading,
      required this.selectedManagers,
      required this.unselectedManagers,
      required this.onFetch});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Text('Report to Line Managers',
                style: GoogleFonts.baloo2(
                    fontSize: 16, fontWeight: FontWeight.bold))),
        const SizedBox(height: 10),
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              height: 45,
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8)),
              child: Row(children: [
                Expanded(
                    child: isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.only(left: 10),
                            child: Row(children: [
                              if (selectedManagers.isEmpty)
                                Text('Select managers',
                                    style: GoogleFonts.baloo2(
                                        fontSize: 16, color: Colors.grey)),
                              ...selectedManagers.map((user) => Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: Row(children: [
                                    Text('${user.firstName} ${user.lastName}',
                                        style: GoogleFonts.baloo2(
                                            fontSize: 16, color: Colors.black)),
                                    const SizedBox(width: 4),
                                    GestureDetector(
                                        onTap: () {
                                          final state =
                                              context.findAncestorStateOfType<
                                                  _AbsenceRequestFormState>()!;
                                          state.setState(() {
                                            selectedManagers.remove(user);
                                            unselectedManagers.add(user);
                                          });
                                        },
                                        child: const Icon(Icons.close,
                                            size: 16, color: Colors.grey)),
                                  ]))),
                            ]),
                          )),
                Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: GestureDetector(
                        onTap: onFetch,
                        child: const Icon(Icons.add, color: Colors.grey))),
              ]),
            )),
        const SizedBox(height: 20),
      ],
    );
  }
}

class AddCoworker extends StatelessWidget {
  final bool isLoading;
  final List<UserModel> selectedCoworkers;
  final List<UserModel> unselectedCoworkers;
  final VoidCallback onFetch;

  const AddCoworker(
      {super.key,
      required this.isLoading,
      required this.selectedCoworkers,
      required this.unselectedCoworkers,
      required this.onFetch});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Text('Add Co-workers',
                style: GoogleFonts.baloo2(
                    fontSize: 16, fontWeight: FontWeight.bold))),
        const SizedBox(height: 10),
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              height: 45,
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8)),
              child: Row(children: [
                Expanded(
                    child: isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.only(left: 10),
                            child: Row(children: [
                              if (selectedCoworkers.isEmpty)
                                Text('Select co-workers',
                                    style: GoogleFonts.baloo2(
                                        fontSize: 16, color: Colors.grey)),
                              ...selectedCoworkers.map((user) => Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: Row(children: [
                                    Text('${user.firstName} ${user.lastName}',
                                        style: GoogleFonts.baloo2(
                                            fontSize: 16, color: Colors.black)),
                                    const SizedBox(width: 4),
                                    GestureDetector(
                                        onTap: () {
                                          final state =
                                              context.findAncestorStateOfType<
                                                  _AbsenceRequestFormState>()!;
                                          state.setState(() {
                                            selectedCoworkers.remove(user);
                                            unselectedCoworkers.add(user);
                                          });
                                        },
                                        child: const Icon(Icons.close,
                                            size: 16, color: Colors.grey)),
                                  ]))),
                            ]),
                          )),
                Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: GestureDetector(
                        onTap: onFetch,
                        child: const Icon(Icons.add, color: Colors.grey))),
              ]),
            )),
        const SizedBox(height: 20),
      ],
    );
  }
}

class DatePicker extends StatelessWidget {
  final TextEditingController dateController;

  const DatePicker({super.key, required this.dateController});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Text('Select Date',
                style: GoogleFonts.baloo2(
                    fontSize: 16, fontWeight: FontWeight.bold))),
        const SizedBox(height: 10),
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              height: 45,
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8)),
              child: TextField(
                controller: dateController,
                decoration: InputDecoration(
                  hintText: 'Select date (YYYY-MM-DD)',
                  hintStyle:
                      GoogleFonts.baloo2(fontSize: 16, color: Colors.grey),
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
                    builder: (context, child) => Theme(
                        data: Theme.of(context).copyWith(
                          dialogBackgroundColor: Colors.white,
                          colorScheme: const ColorScheme.light(
                              primary: Color(0xFF2EB67D),
                              onPrimary: Colors.white,
                              surface: Colors.white,
                              onSurface: Colors.black),
                          textButtonTheme: TextButtonThemeData(
                              style: TextButton.styleFrom(
                                  foregroundColor: const Color(0xFF2EB67D))),
                        ),
                        child: child!),
                  );
                  if (pickedDate != null) {
                    final state = context
                        .findAncestorStateOfType<_AbsenceRequestFormState>()!;
                    state.setState(() => dateController.text =
                        pickedDate.toIso8601String().split('T')[0]);
                  }
                },
              ),
            )),
        const SizedBox(height: 20),
      ],
    );
  }
}

class TimePicker extends StatelessWidget {
  final TimeOfDay? leaveFromTime;
  final TimeOfDay? leaveToTime;
  final Function(TimeOfDay) onFromTimeSelected;
  final Function(TimeOfDay) onToTimeSelected;

  const TimePicker({
    super.key,
    required this.leaveFromTime,
    required this.leaveToTime,
    required this.onFromTimeSelected,
    required this.onToTimeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Text('Select Time',
                style: GoogleFonts.baloo2(
                    fontSize: 16, fontWeight: FontWeight.bold))),
        const SizedBox(height: 10),
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                    child: GestureDetector(
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                      builder: (context, child) => Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: const ColorScheme.light(
                                primary: Color(0xFF2EB67D),
                                onPrimary: Colors.white,
                                surface: Colors.white,
                                onSurface: Colors.black),
                            textButtonTheme: TextButtonThemeData(
                                style: TextButton.styleFrom(
                                    foregroundColor: const Color(0xFF2EB67D))),
                          ),
                          child: child!),
                    );
                    if (time != null) onFromTimeSelected(time);
                  },
                  child: Container(
                    height: 45,
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8)),
                    child: Center(
                        child: Text(
                      leaveFromTime != null
                          ? '${leaveFromTime!.hour.toString().padLeft(2, '0')}:${leaveFromTime!.minute.toString().padLeft(2, '0')}'
                          : 'From Time',
                      style: GoogleFonts.baloo2(
                          fontSize: 16,
                          color: leaveFromTime != null
                              ? Colors.black
                              : Colors.grey),
                    )),
                  ),
                )),
                const SizedBox(width: 10),
                Expanded(
                    child: GestureDetector(
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                      builder: (context, child) => Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: const ColorScheme.light(
                                primary: Color(0xFF2EB67D),
                                onPrimary: Colors.white,
                                surface: Colors.white,
                                onSurface: Colors.black),
                            textButtonTheme: TextButtonThemeData(
                                style: TextButton.styleFrom(
                                    foregroundColor: const Color(0xFF2EB67D))),
                          ),
                          child: child!),
                    );
                    if (time != null) onToTimeSelected(time);
                  },
                  child: Container(
                    height: 45,
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8)),
                    child: Center(
                        child: Text(
                      leaveToTime != null
                          ? '${leaveToTime!.hour.toString().padLeft(2, '0')}:${leaveToTime!.minute.toString().padLeft(2, '0')}'
                          : 'To Time',
                      style: GoogleFonts.baloo2(
                          fontSize: 16,
                          color:
                              leaveToTime != null ? Colors.black : Colors.grey),
                    )),
                  ),
                )),
              ],
            )),
        const SizedBox(height: 20),
      ],
    );
  }
}
