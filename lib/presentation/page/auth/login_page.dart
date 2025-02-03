import 'package:empowerhr_moblie/core/dialog_utils.dart';
import 'package:empowerhr_moblie/presentation/bloc/auth/auth_bloc.dart';
import 'package:empowerhr_moblie/presentation/bloc/auth/auth_event.dart';
import 'package:empowerhr_moblie/presentation/bloc/auth/auth_state.dart';
import 'package:empowerhr_moblie/presentation/page/auth/forgot_password_page.dart';
import 'package:empowerhr_moblie/presentation/page/bottom_nav.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with WidgetsBindingObserver {
  bool isPasswordVisible = false;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  bool isKeyboardVisible = false;
  bool isEmailEmpty = false;
  bool isPasswordEmpty = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    final bottomInset = WidgetsBinding.instance.window.viewInsets.bottom;
    setState(() {
      isKeyboardVisible = bottomInset > 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4B5563),
      body: BlocProvider(
        create: (context) => AuthBloc(),
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthLoading) {
              DialogUtils.showLoadingDialog(context);
            } else if (state is AuthSuccess) {
              print("Login successful! Navigating to BottomNavBar...");

              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      BottomNavBar(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                ),
              );
            } else if (state is AuthFailure) {
              DialogUtils.dismissDialog(context);
              DialogUtils.showErrorDialog(context, state.message);
            }
          },
          builder: (context, state) {
            return GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(left: 15, top: 25),
                      child: Image.asset('assets/LOGO-02.png'),
                    ),
                  ),
                  Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      padding:
                          EdgeInsets.only(top: isKeyboardVisible ? 60 : 170),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFFFFF),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          ),
                        ),
                        width: double.infinity,
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  children: [
                                    const SizedBox(height: 75),
                                    Text(
                                      "Welcome Back!",
                                      style: GoogleFonts.poppins(
                                        fontSize: 40,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 60),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Container(
                                        margin: const EdgeInsets.only(left: 20),
                                        child: Text("Email"),
                                      ),
                                    ),
                                    const SizedBox(height: 13),
                                    Container(
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFDEE3E7),
                                        borderRadius: BorderRadius.circular(15),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.25),
                                            offset: const Offset(0, 4),
                                            blurRadius: 2,
                                          ),
                                        ],
                                        border: Border.all(
                                          color: isEmailEmpty
                                              ? Colors.red
                                              : Colors.transparent,
                                          width: 2,
                                        ),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12),
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 20),
                                      child: TextField(
                                        cursorColor: const Color(0xFF2EB67D),
                                        controller: emailController,
                                        focusNode: _emailFocus,
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                          hintText: "Enter your Email here",
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  vertical: 13),
                                          hintStyle: GoogleFonts.poppins(
                                            fontSize: 15,
                                            color: isEmailEmpty
                                                ? Colors.red
                                                : Colors.grey,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Container(
                                        margin: const EdgeInsets.only(left: 20),
                                        child: Text("Password"),
                                      ),
                                    ),
                                    const SizedBox(height: 13),
                                    Container(
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFDEE3E7),
                                        borderRadius: BorderRadius.circular(15),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.25),
                                            offset: const Offset(0, 4),
                                            blurRadius: 2,
                                          ),
                                        ],
                                        border: Border.all(
                                          color: isPasswordEmpty
                                              ? Colors.red
                                              : Colors.transparent,
                                          width: 2,
                                        ),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12),
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 20),
                                      child: TextField(
                                        cursorColor: const Color(0xFF2EB67D),
                                        controller: passwordController,
                                        focusNode: _passwordFocus,
                                        obscureText: !isPasswordVisible,
                                        textAlignVertical:
                                            TextAlignVertical.center,
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                          hintText: "Enter your Password here",
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  vertical: 13),
                                          hintStyle: GoogleFonts.poppins(
                                            fontSize: 15,
                                            color: isPasswordEmpty
                                                ? Colors.red
                                                : Colors.grey,
                                          ),
                                          suffixIcon: IconButton(
                                            icon: Icon(
                                              isPasswordVisible
                                                  ? Icons.visibility
                                                  : Icons.visibility_off,
                                              color: Colors.grey,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                isPasswordVisible =
                                                    !isPasswordVisible;
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            PageRouteBuilder(
                                              pageBuilder: (context, animation,
                                                      secondaryAnimation) =>
                                                  ForgotPassword_page(),
                                              transitionsBuilder: (context,
                                                  animation,
                                                  secondaryAnimation,
                                                  child) {
                                                return FadeTransition(
                                                  opacity: animation,
                                                  child: child,
                                                );
                                              },
                                            ),
                                          );
                                        },
                                        child: Container(
                                            margin: const EdgeInsets.only(
                                                right: 20),
                                            child: Text(
                                              'Forgot password?',
                                              style: GoogleFonts.poppins(
                                                fontSize: 14,
                                                color: const Color(0xFF2EB67D),
                                                fontWeight: FontWeight.w500,
                                              ),
                                            )),
                                      ),
                                    ),
                                    const SizedBox(height: 40),
                                    ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          isEmailEmpty =
                                              emailController.text.isEmpty;
                                          isPasswordEmpty =
                                              passwordController.text.isEmpty;
                                        });

                                        if (!isEmailEmpty && !isPasswordEmpty) {
                                          print("Login button pressed");

                                          context.read<AuthBloc>().add(
                                                LoginEvent(
                                                  email: emailController.text,
                                                  password:
                                                      passwordController.text,
                                                ),
                                              );
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFF2EB67D),
                                        foregroundColor: Colors.white,
                                        fixedSize: const Size(190, 45),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                      ),
                                      child: Text(
                                        "Login",
                                        style: GoogleFonts.poppins(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hintText,
    bool isPassword = false,
    bool isEmailField = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.only(left: 20),
            child: Text(label),
          ),
        ),
        const SizedBox(height: 13),
        Container(
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFFDEE3E7),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                offset: const Offset(0, 4),
                blurRadius: 2,
              ),
            ],
            border: Border.all(
              color: (isEmailField && isEmailEmpty) ||
                      (!isEmailField && isPasswordEmpty)
                  ? Colors.red
                  : Colors.transparent,
              width: 2,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          margin: const EdgeInsets.symmetric(horizontal: 20),
          child: TextField(
            cursorColor: const Color(0xFF2EB67D),
            obscureText: isPassword && !isPasswordVisible,
            controller: controller,
            focusNode: focusNode,
            textAlignVertical: TextAlignVertical.center,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hintText,
              isCollapsed: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
              hintStyle: GoogleFonts.poppins(
                fontSize: 15,
                color: (isEmailField && isEmailEmpty) ||
                        (!isEmailField && isPasswordEmpty)
                    ? Colors.red
                    : Colors.grey,
              ),
              suffixIcon: isPassword
                  ? Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: IconButton(
                        icon: Icon(
                          isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            isPasswordVisible = !isPasswordVisible;
                          });
                        },
                      ),
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}
