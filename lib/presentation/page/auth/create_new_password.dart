import 'package:empowerhr_moblie/presentation/bloc/forgot_password/forgot_password_bloc.dart';
import 'package:empowerhr_moblie/presentation/bloc/forgot_password/forgot_password_event.dart';
import 'package:empowerhr_moblie/presentation/bloc/forgot_password/forgot_password_state.dart';
import 'package:empowerhr_moblie/presentation/page/auth/verify_email.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';


class CreateNewPassword extends StatefulWidget {
  CreateNewPassword({super.key});

  @override
  State<CreateNewPassword> createState() => _CreateNewPassword_pageState();
}

class _CreateNewPassword_pageState extends State<CreateNewPassword> {
  bool isEmailFocus = false;
  TextEditingController emailController = TextEditingController();
  FocusNode _emailFocus = FocusNode();
  @override
  void initState() {
    super.initState();
    _emailFocus.addListener(() {
      setState(() {
        isEmailFocus = _emailFocus.hasFocus;
      });
    });
  }

  void dispose() {
    emailController.dispose();
    _emailFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF),
        title: Text(
          'Create New Password',
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
            if (state is EmailSubmittedState) {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => VerifyEmail(
                          email: emailController.text,
                        )),
              );
            }
          },
          builder: (context, state) {
            if (state is ForgotPasswordLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            return SingleChildScrollView(
              child: Column(
                children: [
                  Center(
                    child: Container(
                      margin:
                          const EdgeInsets.only(top: 65, left: 50, right: 50),
                      child: Image.asset('assets/change_new_password_IMG.png'),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 20, left: 20, right: 20),
                    child: Text(
                      'Your New Password Must Be Different From Previously Used Password.',
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
                  const SizedBox(
                    height: 55,
                  ),
                  _buildTextField(
                    label: "New Pasword",
                    controller: emailController,
                    focusNode: _emailFocus,
                    hintText: "Enter your New Pasword here",
                  ),
                   const SizedBox(
                    height: 20,
                  ),
                   _buildTextField(
                    label: "Confirm Password",
                    controller: emailController,
                    focusNode: _emailFocus,
                    hintText: "Confirm your Password  New Pasword here",
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                   Text(
                    'Change password',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF2EB67D),
                      decoration: TextDecoration.underline,
                      decorationColor: const Color(0xFF2EB67D),
                    ),
                  ),
                   const SizedBox(
                    height: 40,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      final email = emailController.text.trim();

                      if (email.isNotEmpty) {
                        context
                            .read<ForgotPasswordBloc>()
                            .add(SubmitEmailEvent(email));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text('Please enter a valid email address')),
                        );
                      }
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
                      "Save",
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

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hintText,
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
                blurRadius: 4,
              ),
            ],
          ),
          margin: const EdgeInsets.only(left: 31, right: 31),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: TextField(
            cursorColor: const Color(0xFF2EB67D),
            controller: controller,
            focusNode: focusNode,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hintText,
              hintStyle: GoogleFonts.poppins(
                textStyle: const TextStyle(
                  fontSize: 15,
                  color: Colors.grey,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 13),
            ),
          ),
        ),
      ],
    );
  }
}
