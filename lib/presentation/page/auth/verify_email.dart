import 'package:empowerhr_moblie/domain/usecases/verify_otp_usecase.dart';
import 'package:empowerhr_moblie/presentation/page/auth/create_new_password.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VerifyEmail extends StatefulWidget {
  final String email;

  VerifyEmail({super.key, required this.email});

  @override
  State<VerifyEmail> createState() => VerifyEmailState();
}

class VerifyEmailState extends State<VerifyEmail> {
  List<TextEditingController> otpControllers =
      List.generate(6, (index) => TextEditingController());
  List<FocusNode> otpFocusNodes = List.generate(6, (index) => FocusNode());
  bool isLoading = false; // Trạng thái loading

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
      body: Stack(
        children: [
          SingleChildScrollView(
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
                    'Please Enter The 6 Digit Code Sent To ${widget.email}',
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
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 16,
                  runSpacing: 16,
                  children: List.generate(6, (index) {
                    return _buildOtpField(
                      controller: otpControllers[index],
                      focusNode: otpFocusNodes[index],
                      onChanged: () {
                        if (index < 5) {
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
                  onPressed: isLoading
                      ? null // Vô hiệu hóa nút khi đang loading
                      : () async {
                          final otpCode = otpControllers.map((c) => c.text).join();

                          if (otpCode.length != 6) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please enter a 6-digit OTP'),
                              ),
                            );
                            return;
                          }

                          setState(() {
                            isLoading = true; // Bật loading
                          });

                          try {
                            // Gọi API verifyOTP
                            final result = await verifyOTP(widget.email, otpCode);

                            // Đợi 3 giây trước khi xử lý kết quả
                            await Future.delayed(const Duration(seconds: 3));

                            if (result['status'] == 200) {
                              // Chuyển hướng sang CreateNewPassword
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CreateNewPassword(email:widget.email),
                                ),
                              );
                            } else {
                              // Hiển thị thông báo lỗi
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(result['message']),
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
                const SizedBox(height: 30),
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
          contentPadding: EdgeInsets.symmetric(vertical: 20),
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