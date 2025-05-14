import 'package:empowerhr_moblie/domain/usecases/create_new_passwors_usecase.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:empowerhr_moblie/presentation/page/auth/login_page.dart';

class CreateNewPassword extends StatefulWidget {
  final String email;
  const CreateNewPassword({super.key, required this.email});

  @override
  State<CreateNewPassword> createState() => _CreateNewPassword_pageState();
}

class _CreateNewPassword_pageState extends State<CreateNewPassword> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final FocusNode _newPasswordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();
  bool isMessageVisible = false;
  bool isLoading = false;
  bool isNewPasswordVisible = false;
  bool isConfirmPasswordVisible = false;
  bool _hasLengthError = false; // Biến theo dõi lỗi độ dài mật khẩu

  @override
  void initState() {
    super.initState();
    setState(() {
      isMessageVisible = true;
    });
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          isMessageVisible = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _newPasswordFocus.dispose();
    _confirmPasswordFocus.dispose();
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
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 65, left: 50, right: 50),
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
                const SizedBox(height: 20),
                AnimatedOpacity(
                  opacity: isMessageVisible ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 50),
                    child: Text(
                      'Xác nhận mã OTP thành công, vui lòng thay đổi mật khẩu mới',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.green,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                _buildTextField(
                  label: "New Password",
                  controller: _newPasswordController,
                  focusNode: _newPasswordFocus,
                  hintText: "Enter your new password",
                  isPassword: true,
                  isPasswordVisible: isNewPasswordVisible,
                  onToggleVisibility: () {
                    setState(() {
                      isNewPasswordVisible = !isNewPasswordVisible;
                    });
                  },
                  hasError: _hasLengthError && _newPasswordController.text.length < 8,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  label: "Confirm Password",
                  controller: _confirmPasswordController,
                  focusNode: _confirmPasswordFocus,
                  hintText: "Confirm your new password",
                  isPassword: true,
                  isPasswordVisible: isConfirmPasswordVisible,
                  onToggleVisibility: () {
                    setState(() {
                      isConfirmPasswordVisible = !isConfirmPasswordVisible;
                    });
                  },
                  hasError: _hasLengthError && _confirmPasswordController.text.length < 8,
                ),
                const SizedBox(height: 20),
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
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          final newPassword = _newPasswordController.text.trim();
                          final confirmPassword = _confirmPasswordController.text.trim();

                          // Kiểm tra trường rỗng
                          if (newPassword.isEmpty || confirmPassword.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please fill in all fields'),
                              ),
                            );
                            return;
                          }

                          // Kiểm tra độ dài mật khẩu
                          if (newPassword.length < 8 || confirmPassword.length < 8) {
                            setState(() {
                              _hasLengthError = true;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Password must be at least 8 characters'),
                              ),
                            );
                            return;
                          }

                          // Kiểm tra mật khẩu khớp
                          if (newPassword != confirmPassword) {
                            setState(() {
                              _hasLengthError = false; // Reset lỗi độ dài nếu có
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Passwords do not match'),
                              ),
                            );
                            return;
                          }

                          // Nếu qua tất cả kiểm tra, reset lỗi và tiến hành gọi API
                          setState(() {
                            _hasLengthError = false;
                            isLoading = true;
                          });

                          try {
                            final result = await resetPassword(widget.email, newPassword);

                            if (result['status'] == 200) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(result['message']),
                                ),
                              );
                              await Future.delayed(const Duration(seconds: 2));
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LoginPage(),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(result['message']),
                                ),
                              );
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error: $e'),
                              ),
                            );
                          } finally {
                            setState(() {
                              isLoading = false;
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
                    "Save",
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

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hintText,
    bool isPassword = false,
    required bool isPasswordVisible,
    required VoidCallback onToggleVisibility,
    bool hasError = false, // Thêm tham số để kiểm tra lỗi
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
            border: Border.all(
              color: hasError ? Colors.red : Colors.transparent, // Đổi màu viền nếu có lỗi
              width: 2,
            ),
          ),
          margin: const EdgeInsets.only(left: 31, right: 31),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  cursorColor: const Color(0xFF2EB67D),
                  controller: controller,
                  focusNode: focusNode,
                  obscureText: isPassword && !isPasswordVisible,
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
              IconButton(
                icon: Icon(
                  isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: const Color(0xFF2EB67D),
                ),
                onPressed: onToggleVisibility,
              ),
            ],
          ),
        ),
      ],
    );
  }
}