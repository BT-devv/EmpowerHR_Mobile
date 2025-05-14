import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UnderDevelopmentPage extends StatelessWidget {
  const UnderDevelopmentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2EB67D), Color(0xFFF9A825)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon biểu tượng code
              const Icon(
                Icons.code,
                size: 80,
                color: Colors.black,
              ),
              const SizedBox(height: 20),
              // Text thông báo
              Text(
                'This function is under developing',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Please do come back later',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20),
              // Icon tên lửa
              Container(
                margin: EdgeInsets.only(left: 50,right: 50,top: 20,bottom: 20),
                child: Image.asset(
                  'assets/commingsoon.png', // Thay bằng đường dẫn ảnh tên lửa của bạn
                ),
              ),
              const SizedBox(height: 30),
              // Nút Close
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Quay lại trang chủ
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2EB67D),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Close and get back to Home page',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
