import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PersonalInformationPage extends StatelessWidget {
  const PersonalInformationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
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
                // Nút Back ở góc trên bên trái
                Positioned(
                  top: 40, // Đặt gần góc trên để nằm trên background
                  left: 16, // Đặt gần góc trái
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors
                              .black, // Đổi màu trắng để nổi bật trên background
                          size: 30,
                        ),
                        onPressed: () {
                          Navigator.pop(context); // Quay lại trang trước
                        },
                      ),
                      Text('Back'),
                    ],
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
            SizedBox(height: 200 * 2 / 3),
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
            Text(
              "ID: 990009923",
              style: GoogleFonts.baloo2(
                textStyle: const TextStyle(
                    fontSize: 20,
                    color: Color(0xFF2EB67D),
                    fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
            // Personal Information Section
            Row(
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
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildTextField("First Name", "Anh Tung", false),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildTextField("Middle Name", "None", false),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildTextField("Last Name", "Do", false),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildTextField("Alias", "Luffy", false),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildTextField("D.O.B", "18 Jun 1999", false),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildTextField("Gender", "Male", false),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Contact Detail Section
            Row(
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
            const SizedBox(height: 10),
            _buildTextField("Phone Number", "(+84) 900900023", false),
            const SizedBox(height: 10),
            _buildTextField("Personal Email", "tungdo1806@gmail.com", false),
            const SizedBox(height: 10),
            _buildTextField(
                "Work Email", "anhtung.do18@hrempowered.com", false),
            const SizedBox(height: 10),
            _buildTextField(
              "Address",
              "112 Floor 1, Tower 4, The Sun Avenue,\n28 Mai Chi Tho",
              false,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildTextField("Province", "District 2", false),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildTextField("City", "Thu Duc City", false),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildTextField("Postcode", "700000", false),
            const SizedBox(height: 20),

            // Bank Account Information Section
            Row(
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
            const SizedBox(height: 10),
            _buildTextField("Owner Name", "Do Anh Tung", false),
            const SizedBox(height: 10),
            _buildTextField(
                "Card Number", "************1234", false, Icons.remove_red_eye),
            const SizedBox(height: 10),
            _buildTextField("Bank Name", "BIDV", false),
            const SizedBox(height: 10),
            _buildTextField("Account Number", "09098923840012", false),
            const SizedBox(height: 20),

            // Employee's Access Section
            Row(
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
            const SizedBox(height: 10),
            _buildTextField("Employee Type", "Full Time", false),
            const SizedBox(height: 10),
            _buildTextField("Department", "Human Resource", false),
            const SizedBox(height: 10),
            _buildTextField("Position", "Human Resources Specialist", false),
            const SizedBox(height: 10),
            _buildTextField("Role", "Vice Chief", false),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildTextField("Start Date", "15 Jan 2025", false),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildTextField("End Date", "N/A", false),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String value, bool showCheckmark,
      [IconData? suffixIcon]) {
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
            border: Border.all(color: Colors.grey[300]!, width: 1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: TextEditingController(text: value),
                  enabled: false, // Vô hiệu hóa chỉnh sửa
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
    );
  }
}
