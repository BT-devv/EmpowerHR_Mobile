import 'package:empowerhr_moblie/domain/usecases/forgot_password.dart';
import 'package:empowerhr_moblie/presentation/page/auth/verify_email.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ForgotPassword_page extends StatefulWidget {
  ForgotPassword_page({super.key});

  @override
  State<ForgotPassword_page> createState() => _ForgotPassword_pageState();
}

class _ForgotPassword_pageState extends State<ForgotPassword_page> {
  bool isEmailFocus = false;
  bool isLoading = false; // Trạng thái loading
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

  @override
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
          'Forgot Password',
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
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                Center(
                  child: Container(
                    margin:
                        const EdgeInsets.only(top: 65, left: 50, right: 50),
                    child: Image.asset('assets/forgotPasswordImg.png'),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 30, left: 50, right: 50),
                  child: Text(
                    'Please Enter Your Email Address To Recieve A Verification Code.',
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
                  height: 85,
                ),
                _buildTextField(
                  label: "Email Address",
                  controller: emailController,
                  focusNode: _emailFocus,
                  hintText: "Enter your Email here",
                ),
                const SizedBox(
                  height: 115,
                ),
                ElevatedButton(
                  onPressed: isLoading
                      ? null 
                      : () async {
                          final email = emailController.text.trim();

                          if (email.isNotEmpty) {
                            setState(() {
                              isLoading = true; 
                            });

                            try {
                              int? status = await forgotPassword(email);

                              await Future.delayed(const Duration(seconds: 1));

                              if (status == 200) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => VerifyEmail(
                                      email: email,
                                    ),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Failed to send OTP. Status: $status',
                                    ),
                                  ),
                                );
                              }
                            } catch (e) {
                              await Future.delayed(const Duration(seconds: 3));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error: $e'),
                                ),
                              );
                            } finally {
                              setState(() {
                                isLoading = false; // Tắt loading
                              });
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('Please enter a valid email address'),
                              ),
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
                    "Send",
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
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