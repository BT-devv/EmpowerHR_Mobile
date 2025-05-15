import 'dart:io';
import 'package:empowerhr_moblie/data/models/user_model.dart';
import 'package:empowerhr_moblie/data/service/api_service.dart';
import 'package:empowerhr_moblie/data/service/socket_service.dart';
import 'package:empowerhr_moblie/presentation/bloc/user_info/user_bloc.dart';
import 'package:empowerhr_moblie/presentation/bloc/user_info/user_event.dart';
import 'package:empowerhr_moblie/presentation/bloc/user_info/user_state.dart';
import 'package:empowerhr_moblie/presentation/page/account/employee_rights.dart';
import 'package:empowerhr_moblie/presentation/page/account/personal_information_page.dart';
import 'package:empowerhr_moblie/presentation/page/auth/forgot_password_page.dart';
import 'package:empowerhr_moblie/presentation/page/auth/login_page.dart';
import 'package:empowerhr_moblie/presentation/page/coming_soon.dart';
import 'package:empowerhr_moblie/presentation/page/home/notification_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountPage extends StatefulWidget {
  AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  bool isLoading = false;
  final Map<String, Widget> _pageMapping = {
    "Personal Information": PersonalInformationPage(),
    "Change Password": ForgotPassword_page(),
    "Manage Account Status": const UnderDevelopmentPage(),
    "Manage Notification": const NotificationPage(),
    "Change theme": const UnderDevelopmentPage(),
    "Terms & Condition": const UnderDevelopmentPage(),
    "Privacy Policy": const UnderDevelopmentPage(),
    "Employee's rights": const EmployeeRightsPage(),
  };

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UserBloc(ApiService())..add(FetchUser()),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: BlocBuilder<UserBloc, UserState>(
          builder: (context, state) {
            if (state is UserLoading) {
              return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF2EB67D)));
            }
            if (state is UserError) {
              return Center(child: Text(state.message));
            }
            if (state is UserLoaded) {
              final user = state.user;
              final screenWidth = MediaQuery.of(context).size.width;

              return Stack(
                children: [
                  CustomScrollView(
                    slivers: [
                      SliverList(
                        delegate: SliverChildListDelegate(
                          [
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
                                            image:
                                                AssetImage('assets/avata.png')
                                                    as ImageProvider,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              "${user.firstName} ${user.lastName}",
                              textAlign: TextAlign.center,
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
                                  "${user.employeeID}",
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
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.025),
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
                                    onTap: () =>
                                        _navigateToPersonalInfo(context, user),
                                  ),
                                  const Divider(),
                                  _buildMenuItem(
                                    "Change Password",
                                    Image.asset(
                                      'assets/icons/lock-closed.png',
                                      height: 20,
                                      width: 20,
                                    ),
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ForgotPassword_page(),
                                      ),
                                    ),
                                  ),
                                  const Divider(),
                                  _buildMenuItem(
                                    "Manage Account Status",
                                    Image.asset(
                                      'assets/icons/check-badge.png',
                                      height: 20,
                                      width: 20,
                                    ),
                                    comingSoon: true,
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            UnderDevelopmentPage(),
                                      ),
                                    ),
                                  ),
                                  const Divider(),
                                  _buildMenuItem(
                                    "Manage Notification",
                                    Image.asset(
                                      'assets/icons/bell.png',
                                      height: 20,
                                      width: 20,
                                    ),
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            NotificationPage(),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 10, bottom: 8),
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
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            UnderDevelopmentPage(),
                                      ),
                                    ),
                                  ),
                                  const Divider(),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 10, bottom: 8),
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
                                    comingSoon: true,
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            UnderDevelopmentPage(),
                                      ),
                                    ),
                                  ),
                                  const Divider(),
                                  _buildMenuItem(
                                    "Privacy Policy",
                                    Image.asset(
                                      'assets/icons/hand-raised.png',
                                      height: 20,
                                      width: 20,
                                    ),
                                    comingSoon: true,
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            UnderDevelopmentPage(),
                                      ),
                                    ),
                                  ),
                                  const Divider(),
                                  _buildMenuItem(
                                    "Employee's rights",
                                    Image.asset(
                                      'assets/icons/shield-check.png',
                                      height: 20,
                                      width: 20,
                                    ),
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const EmployeeRightsPage(),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.all(20),
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        setState(() {
                                          isLoading = true;
                                        });
                                        try {
                                          await logout(context);
                                        } catch (error) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                                content: Text(
                                                    'Logout failed: $error')),
                                          );
                                        }
                                        setState(() {
                                          isLoading = false;
                                        });
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFFE7E7E7),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 30, vertical: 10),
                                        minimumSize:
                                            const Size(double.infinity, 50),
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
                      )
                    ],
                  ),
                  if (isLoading)
                    Container(
                      color: Colors.black.withOpacity(0.5),
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF2EB67D),
                        ),
                      ),
                    ),
                ],
              );
            }
            return const Center(child: Text('Unknown state'));
          },
        ),
      ),
    );
  }

  void _navigateToPage(BuildContext context, String title) async {
    setState(() {
      isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 1));

    final page = _pageMapping[title];
    if (page != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => page),
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  void _navigateToPersonalInfo(BuildContext context, UserModel user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PersonalInformationPage(user: user),
      ),
    );
  }

  Widget _buildMenuItem(String title, Widget icon,
      {bool comingSoon = false, VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
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
                        colors: [Colors.red, Colors.orange],
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

Future<void> logout(BuildContext context) async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('idUser');
    print('Token and userId removed from SharedPreferences');
    await NotificationService().clearNotifications();
    print('Notifications cleared');
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
      (Route<dynamic> route) => false,
    );
  } catch (error) {
    print('An error occurred during logout: $error');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Logout failed: $error')),
    );
    rethrow;
  }
}
