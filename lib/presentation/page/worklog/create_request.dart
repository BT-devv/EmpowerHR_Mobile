import 'package:empowerhr_moblie/presentation/page/worklog/absence_form.dart';
import 'package:empowerhr_moblie/presentation/page/worklog/over_time_form.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CreateRequest extends StatefulWidget {
  const CreateRequest({super.key});

  @override
  State<CreateRequest> createState() => _CreateRequestState();
}

class _CreateRequestState extends State<CreateRequest> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Image.asset('assets/create_request_bg.png'),
                Positioned(
                  top: MediaQuery.of(context).padding.top + 16,
                  left: 16,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: const Color.fromRGBO(255, 255, 255, 1),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset('assets/chevron-left.png'),
                          const SizedBox(width: 4),
                          Text(
                            'Back',
                            style: GoogleFonts.baloo2(
                              textStyle: const TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Container(
              margin: EdgeInsets.only(left: 15, right: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      "Service request",
                      style: GoogleFonts.baloo2(
                        textStyle: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF565656),
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                  _buildMenuItem(
                    "Absence request",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AbsenceRequestForm(),
                      ),
                    ),
                  ),
                  const Divider(),
                  _buildMenuItem(
                    "Overtime request",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OverTimeForm(),
                      ),
                    ),
                  ),
                  const Divider(),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(String title, {VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const SizedBox(width: 10),
                Text(
                  title,
                  style: GoogleFonts.baloo2(
                    textStyle: const TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
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
