import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PersonalInformationPage extends StatefulWidget {
  const PersonalInformationPage({super.key});

  @override
  _PersonalInformationPageState createState() => _PersonalInformationPageState();
}

class _PersonalInformationPageState extends State<PersonalInformationPage> {
  final List<FocusNode> _focusNodes = []; // Danh sách FocusNode cho các TextField
  bool _isButtonVisible = false; // Trạng thái hiển thị button
  final List<bool> _isFocusedList = []; // Danh sách trạng thái focus cho từng TextField

  @override
  void initState() {
    super.initState();
    // Khởi tạo FocusNode và trạng thái focus cho từng TextField (23 TextField)
    _focusNodes.addAll(List.generate(23, (index) => FocusNode()));
    _isFocusedList.addAll(List.generate(23, (index) => false)); // Ban đầu không TextField nào được focus

    // Lắng nghe sự thay đổi focus
    for (int i = 0; i < _focusNodes.length; i++) {
      final node = _focusNodes[i];
      node.addListener(() {
        setState(() {
          _isFocusedList[i] = node.hasFocus; // Cập nhật trạng thái focus của TextField tương ứng
          _isButtonVisible = _focusNodes.any((node) => node.hasFocus); // Cập nhật trạng thái button
        });
      });
    }
  }

  @override
  void dispose() {
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Background
                    Container(
                      height: 223,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/background_account.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 40,
                      left: 16,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                    // Avatar
                    Positioned(
                      top: 223 - (200 / 3),
                      left: (screenWidth - 200) / 2,
                      child: Container(
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
                            image: AssetImage('assets/QR_code.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 200 * 2 / 3),
                Text(
                  "Anh Tung Do",
                  style: GoogleFonts.baloo2(
                    textStyle: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
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
                      "990009923",
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
                      IconButton(
                        icon: const Icon(
                          Icons.edit,
                          color: Color(0xFF2EB67D),
                          size: 20,
                        ),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField("First Name", "Anh Tung", true, _focusNodes[0], 0),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildTextField("Middle Name", "None", true, _focusNodes[1], 1),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField("Last Name", "Do", true, _focusNodes[2], 2),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildTextField("Alias", "Luffy", true, _focusNodes[3], 3),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField("D.O.B", "18 Jun 1999", true, _focusNodes[4], 4),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildTextField("Gender", "Male", true, _focusNodes[5], 5),
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
                      IconButton(
                        icon: const Icon(
                          Icons.edit,
                          color: Color(0xFF2EB67D),
                          size: 20,
                        ),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                _buildTextField("Phone Number", "(+84) 900900023", true, _focusNodes[6], 6),
                const SizedBox(height: 10),
                _buildTextField("Personal Email", "tungdo1806@gmail.com", true, _focusNodes[7], 7),
                const SizedBox(height: 10),
                _buildTextField("Work Email", "anhtung.do18@hrempowered.com", false, _focusNodes[8], 8),
                const SizedBox(height: 10),
                _buildTextField(
                  "Address",
                  "112 Floor 1, Tower 4, The Sun Avenue,\n28 Mai Chi Tho",
                  true,
                  _focusNodes[9],
                  9,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField("Province", "District 2", true, _focusNodes[10], 10),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildTextField("City", "Thu Duc City", true, _focusNodes[11], 11),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _buildTextField("Postcode", "700000", true, _focusNodes[12], 12),
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
                _buildTextField("Owner Name", "Do Anh Tung", false, _focusNodes[13], 13),
                const SizedBox(height: 10),
                _buildTextField("Card Number", "************1234", false, _focusNodes[14], 14, Icons.remove_red_eye),
                const SizedBox(height: 10),
                _buildTextField("Bank Name", "BIDV", false, _focusNodes[15], 15),
                const SizedBox(height: 10),
                _buildTextField("Account Number", "09098923840012", false, _focusNodes[16], 16),
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
                _buildTextField("Employee Type", "Full Time", false, _focusNodes[17], 17),
                const SizedBox(height: 10),
                _buildTextField("Department", "Human Resource", false, _focusNodes[18], 18),
                const SizedBox(height: 10),
                _buildTextField("Position", "Human Resources Specialist", false, _focusNodes[19], 19),
                const SizedBox(height: 10),
                _buildTextField("Role", "Vice Chief", false, _focusNodes[20], 20),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField("Start Date", "15 Jan 2025", false, _focusNodes[21], 21),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildTextField("End Date", "N/A", false, _focusNodes[22], 22),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
          // Button cố định ở bottom
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
                  onPressed: () {
                    // Logic khi nhấn button (ví dụ: lưu thay đổi)
                    print("Save button pressed");
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2EB67D), // Màu xanh
                    minimumSize: const Size(double.infinity, 50), // Chiều rộng toàn màn hình
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    "Save",
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
    );
  }

  Widget _buildTextField(String label, String value, bool isEditable, FocusNode focusNode, int focusIndex, [IconData? suffixIcon]) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16),
      child: Column(
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
              color: isEditable ? Colors.white : Colors.grey[300], // Đổi màu nền nếu không editable
              border: Border.all(
                color: _isFocusedList[focusIndex] && isEditable ? const Color(0xFF2EB67D) : Colors.grey[300]!, // Đổi màu viền khi focus
                width: 1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: TextEditingController(text: value),
                    enabled: isEditable, // Kiểm soát trạng thái chỉnh sửa
                    focusNode: focusNode, // Gắn FocusNode
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
                  Icon(
                    suffixIcon,
                    color: Colors.grey,
                    size: 20,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}