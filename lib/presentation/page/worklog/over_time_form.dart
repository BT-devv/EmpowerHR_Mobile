import 'package:empowerhr_moblie/data/models/user_model.dart';
import 'package:empowerhr_moblie/domain/usecases/get_user_by_role.dart';
import 'package:empowerhr_moblie/domain/usecases/request_overtime_usecase.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OverTimeForm extends StatefulWidget {
  const OverTimeForm({super.key});

  @override
  _OverTimeFormState createState() => _OverTimeFormState();
}

class _OverTimeFormState extends State<OverTimeForm> {
  List<UserModel> _managers = [];
  UserModel? _selectedManager;
  bool _isLoadingManagers = false;

  TimeOfDay? _leaveFromTime;
  TimeOfDay? _leaveToTime;
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();

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

  Future<void> _submitOvertimeRequest() async {
    // Kiểm tra các trường bắt buộc
    if (_selectedManager == null) {
      _showSnackBar('Please select a manager', isSuccess: false);
      return;
    }
    if (_dateController.text.isEmpty) {
      _showSnackBar('Please select a date', isSuccess: false);
      return;
    }
    if (_leaveFromTime == null) {
      _showSnackBar('Please select start time', isSuccess: false);
      return;
    }
    if (_leaveToTime == null) {
      _showSnackBar('Please select end time', isSuccess: false);
      return;
    }
    if (_reasonController.text.isEmpty) {
      _showSnackBar('Please enter a reason', isSuccess: false);
      return;
    }
    if (_selectedManager!.employeeID == null) {
      _showSnackBar('Selected manager does not have a valid ID',
          isSuccess: false);
      return;
    }

    // Format startTime và endTime thành HH:mm
    final startTime =
        '${_leaveFromTime!.hour.toString().padLeft(2, '0')}:${_leaveFromTime!.minute.toString().padLeft(2, '0')}';
    final endTime =
        '${_leaveToTime!.hour.toString().padLeft(2, '0')}:${_leaveToTime!.minute.toString().padLeft(2, '0')}';

    // Gọi API requestOvertime
    final result = await requestOvertime(
      projectManager: _selectedManager!.employeeID!,
      date: _dateController.text,
      startTime: startTime,
      endTime: endTime,
      reason: _reasonController.text,
    );

    // Hiển thị kết quả
    _showSnackBar(result['message'], isSuccess: result['success']);
    if (result['success']) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Image.asset('assets/overtime_bg.png'),
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
                        color: const Color.fromRGBO(255, 255, 255, 1),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
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
              ],
            ),
            const SizedBox(height: 20),
            _buildReportToLineManager(),
            TimePicker(
              leaveFromTime: _leaveFromTime,
              leaveToTime: _leaveToTime,
              onFromTimeSelected: (time) =>
                  setState(() => _leaveFromTime = time),
              onToTimeSelected: (time) => setState(() => _leaveToTime = time),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
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
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Text(
                'Reason of your over-time:',
                style: GoogleFonts.baloo2(
                  textStyle: const TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: TextField(
                controller: _reasonController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: '',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                ),
                style: GoogleFonts.baloo2(
                    textStyle:
                        const TextStyle(fontSize: 16, color: Colors.black)),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(left: 60, right: 60, bottom: 20),
              child: ElevatedButton(
                onPressed: _submitOvertimeRequest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2EB67D),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'SUBMIT',
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
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _dateController.dispose();
    _reasonController.dispose();
    super.dispose();
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
            child: Text('Your over-time start from:',
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
