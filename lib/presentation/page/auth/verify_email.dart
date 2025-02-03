import 'package:empowerhr_moblie/presentation/bloc/forgot_password/forgot_password_bloc.dart';
import 'package:empowerhr_moblie/presentation/bloc/forgot_password/forgot_password_event.dart';
import 'package:empowerhr_moblie/presentation/bloc/forgot_password/forgot_password_state.dart';
import 'package:empowerhr_moblie/presentation/page/auth/create_new_password.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class VerifyEmail extends StatefulWidget {
  final String email;

  VerifyEmail({super.key, required this.email});

  @override
  State<VerifyEmail> createState() => VerifyEmailState();
}

class VerifyEmailState extends State<VerifyEmail> {
  List<TextEditingController> otpControllers =
      List.generate(4, (index) => TextEditingController());
  List<FocusNode> otpFocusNodes = List.generate(4, (index) => FocusNode());

  @override
  void dispose() {
    for (var controller in otpControllers) {
      controller.dispose();
    }
    for (var focusNode in otpFocusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF),
        title: Text(
          'Verify Your Email',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFFFFFFF),
      body: BlocProvider(
        create: (_) => ForgotPasswordBloc(),
        child: BlocConsumer<ForgotPasswordBloc, ForgotPasswordState>(
          listener: (context, state) {
            if (state is OtpVerifiedState) {
              // Điều hướng sang trang đổi mật khẩu
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CreateNewPassword()),
              );
            } else if (state is ForgotPasswordError) {
              // Hiển thị thông báo lỗi
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  Center(
                    child: Container(
                      margin:
                          const EdgeInsets.only(top: 65, left: 50, right: 50),
                      child: Image.asset('assets/verifyImg.png'),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 30, left: 50, right: 50),
                    child: Text(
                      'Please Enter The 4 Digit Code Sent To ${widget.email}',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 65),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(4, (index) {
                      return _buildOtpField(
                        controller: otpControllers[index],
                        focusNode: otpFocusNodes[index],
                        onChanged: () {
                          if (index < 3) {
                            FocusScope.of(context)
                                .requestFocus(otpFocusNodes[index + 1]);
                          } else {
                            otpFocusNodes[index].unfocus();
                          }
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 40),
                  Text(
                    'Resend OTP',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF2EB67D),
                      decoration: TextDecoration.underline,
                      decorationColor: const Color(0xFF2EB67D),
                    ),
                  ),
                  const SizedBox(height: 50),
                  ElevatedButton(
                    onPressed: () {
                      final otpCode = otpControllers.map((c) => c.text).join();
                      context
                          .read<ForgotPasswordBloc>()
                          .add(VerifyOtpEvent(otpCode));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2EB67D),
                      foregroundColor: Colors.white,
                      fixedSize: const Size(190, 45),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: Text(
                      "Send",
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
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

  Widget _buildOtpField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required VoidCallback onChanged,
  }) {
    return Container(
      width: 57,
      height: 73,
      decoration: BoxDecoration(
        color: const Color(0xFFDEE3E7),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            offset: const Offset(0, 4),
            blurRadius: 4,
          ),
        ],
      ),
      margin: const EdgeInsets.only(left: 8, right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        maxLength: 1,
        cursorColor: const Color(0xFF2EB67D),
        decoration: const InputDecoration(
          contentPadding: const EdgeInsets.symmetric(vertical: 20),
          border: InputBorder.none,
          counterText: "",
        ),
        onChanged: (value) {
          if (value.length == 1) {
            onChanged();
          }
        },
      ),
    );
  }
}
