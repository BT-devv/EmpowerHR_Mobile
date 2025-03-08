import 'package:empowerhr_moblie/presentation/page/account/Change_password_page.dart';
import 'package:empowerhr_moblie/presentation/page/account/change_theme_Page.dart';
import 'package:empowerhr_moblie/presentation/page/account/employee_rights_page.dart';
import 'package:empowerhr_moblie/presentation/page/account/manage_account_status_page.dart';
import 'package:empowerhr_moblie/presentation/page/account/manage_notification_page.dart';
import 'package:empowerhr_moblie/presentation/page/account/personal_information_page.dart';
import 'package:empowerhr_moblie/presentation/page/account/privacy_policy_page.dart';
import 'package:empowerhr_moblie/presentation/page/account/terms_and_condition_page.dart';
import 'package:empowerhr_moblie/presentation/page/account/two_factor_auth_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AccountPage extends StatelessWidget {
   AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SingleChildScrollView(
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
                      image: AssetImage('assets/background_account.png'),
                      fit: BoxFit.cover,
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
                        color:  Colors.black, 
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
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.025),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      "ACCOUNT SETTING",
                      style: GoogleFonts.baloo2(
                        textStyle: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF565656),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  _buildMenuItem(
                    "Personal Information",
                    Image.asset(
                      'assets/icons/user-circle.png',
                      height: 20,
                      width: 20,
                    ),
                    onTap: () => _navigateToPage(context, "Personal Information"),
                  ),
                  const Divider(),
                  _buildMenuItem(
                    "Change Password",
                    Image.asset(
                      'assets/icons/lock-closed.png',
                      height: 20,
                      width: 20,
                    ),
                    onTap: () => _navigateToPage(context, "Change Password"),
                  ),
                  const Divider(),
                  _buildMenuItem(
                    "Manage Account Status",
                    Image.asset(
                      'assets/icons/check-badge.png',
                      height: 20,
                      width: 20,
                    ),
                    onTap: () => _navigateToPage(context, "Manage Account Status"),
                  ),
                  const Divider(),
                  _buildMenuItem(
                    "Manage Notification",
                    Image.asset(
                      'assets/icons/bell.png',
                      height: 20,
                      width: 20,
                    ),
                    onTap: () => _navigateToPage(context, "Manage Notification"),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 8),
                    child: Text(
                      "SYSTEM CONFIGURATIONS",
                      style: GoogleFonts.baloo2(
                        textStyle: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF565656),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  _buildMenuItem(
                    "Change theme",
                    Image.asset(
                      'assets/icons/moon.png',
                      height: 20,
                      width: 20,
                    ),
                    comingSoon: true,
                    onTap: () => _navigateToPage(context, "Change theme"),
                  ),
                  const Divider(),
                  _buildMenuItem(
                    "Two-factor authentication",
                    Image.asset(
                      'assets/icons/finger-print.png',
                      height: 20,
                      width: 20,
                    ),
                    comingSoon: true,
                    onTap: () => _navigateToPage(context, "Two-factor authentication"),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 8),
                    child: Text(
                      "Company’s License",
                      style: GoogleFonts.baloo2(
                        textStyle: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF565656),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  _buildMenuItem(
                    "Terms & Condition",
                    Image.asset(
                      'assets/icons/building-library.png',
                      height: 20,
                      width: 20,
                    ),
                    onTap: () => _navigateToPage(context, "Terms & Condition"),
                  ),
                  const Divider(),
                  _buildMenuItem(
                    "Privacy Policy",
                    Image.asset(
                      'assets/icons/hand-raised.png',
                      height: 20,
                      width: 20,
                    ),
                    onTap: () => _navigateToPage(context, "Privacy Policy"),
                  ),
                  const Divider(),
                  _buildMenuItem(
                    "Employee's rights",
                    Image.asset(
                      'assets/icons/shield-check.png',
                      height: 20,
                      width: 20,
                    ),
                    onTap: () => _navigateToPage(context, "Employee's rights"),
                  ),
                  // Nút Log out với viền nét đứt
                  Container(
                    margin: const EdgeInsets.all(20),
                    child: ElevatedButton(
                      onPressed: () {
                        // Xử lý đăng xuất
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFE7E7E7),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 10),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: Text(
                        "LOG OUT",
                        style: GoogleFonts.baloo2(
                          textStyle: const TextStyle(
                            fontSize: 16,
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Hàm điều hướng đến trang tương ứng
  void _navigateToPage(BuildContext context, String title) {
    final page = _pageMapping[title];
    if (page != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => page),
      );
    }
  }

  // Mapping giữa title và trang đích
  final Map<String, Widget> _pageMapping = {
    "Personal Information": const PersonalInformationPage(),
    "Change Password": const ChangePasswordPage(),
    "Manage Account Status": const ManageAccountStatusPage(),
    "Manage Notification": const ManageNotificationPage(),
    "Change theme": const ChangeThemePage(),
    "Two-factor authentication": const TwoFactorAuthPage(),
    "Terms & Condition": const TermsAndConditionPage(),
    "Privacy Policy": const PrivacyPolicyPage(),
    "Employee's rights": const EmployeeRightsPage(),
  };

  Widget _buildMenuItem(String title, Widget icon,
      {bool comingSoon = false, VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                icon,
                const SizedBox(width: 10),
                Text(
                  title,
                  style: GoogleFonts.baloo2(
                    textStyle: const TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                if (comingSoon)
                  ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return const LinearGradient(
                        colors: [
                          Colors.red,
                          Colors.orange,
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ).createShader(bounds);
                    },
                    child: Text(
                      "coming soon",
                      style: GoogleFonts.baloo2(
                        textStyle: const TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                const SizedBox(width: 5),
                Image.asset(
                  "assets/icons/arrow-small-right.png",
                  height: 16,
                  width: 16,
                  color: const Color(0xFF2EB67D),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}