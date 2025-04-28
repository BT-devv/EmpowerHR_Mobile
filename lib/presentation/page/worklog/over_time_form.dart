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

  final TextEditingController _startHourController = TextEditingController();
  final TextEditingController _startMinuteController = TextEditingController();
  final TextEditingController _endHourController = TextEditingController();
  final TextEditingController _endMinuteController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();

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
    if (_startHourController.text.isEmpty || _startMinuteController.text.isEmpty) {
      _showSnackBar('Please enter start time', isSuccess: false);
      return;
    }
    if (_endHourController.text.isEmpty || _endMinuteController.text.isEmpty) {
      _showSnackBar('Please enter end time', isSuccess: false);
      return;
    }
    if (_reasonController.text.isEmpty) {
      _showSnackBar('Please enter a reason', isSuccess: false);
      return;
    }

    // Thêm kiểm tra cho employeeID
    if (_selectedManager!.employeeID == null) {
      _showSnackBar('Selected manager does not have a valid ID', isSuccess: false);
      return;
    }

    // Format startTime và endTime thành HH:mm
    final startTime = '${_startHourController.text.padLeft(2, '0')}:${_startMinuteController.text.padLeft(2, '0')}';
    final endTime = '${_endHourController.text.padLeft(2, '0')}:${_endMinuteController.text.padLeft(2, '0')}';

    // Gọi API requestOvertime
    final result = await requestOvertime(
      projectManager: _selectedManager!.employeeID!, // An toàn vì đã kiểm tra null
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

            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Text(
                'Your over-time start from:',
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 50,
                    child: TextField(
                      controller: _startHourController,
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
                      controller: _startMinuteController,
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
                      controller: _endHourController,
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
                      controller: _endMinuteController,
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
                    hintStyle: GoogleFonts.baloo2(fontSize: 16, color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.only(left: 10, top: 8),
                    suffixIcon: const Icon(Icons.calendar_today, color: Colors.grey, size: 20),
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
                        _dateController.text = pickedDate.toIso8601String().split('T')[0];
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
}