import 'package:empowerhr_moblie/domain/usecases/QRCodeResponse_usecase.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import 'package:intl/intl.dart';
import 'dart:convert'; // Để decode base64

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<String> qrBackgrounds = [
    'assets/HomepageQR.png',
    'assets/HomepageQR(1).png',
    'assets/HomepageQR(2).png',
    'assets/HomepageQR(3).png',
  ];

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color(0xFF2EB67D),
      statusBarIconBrightness: Brightness.light,
    ));
    DateTime now = DateTime.now();
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    String todayDate = DateFormat('EEEE, MMMM d ').format(now);
    List<Map<String, dynamic>> daysOfWeek = [];
    DateTime startOfWeek =
        now.subtract(Duration(days: now.weekday - 1)); // Bắt đầu từ Thứ Hai
    for (int i = 0; i < 7; i++) {
      DateTime day = startOfWeek.add(Duration(days: i));
      String dayName = ['Mo', 'Tu', 'We', 'Th', 'Fi', 'Sa', 'Su'][i];
      daysOfWeek.add({
        'name': dayName,
        'date': day.day,
        'isToday': day.day == now.day &&
            day.month == now.month &&
            day.year == now.year,
      });
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: screenHeight * 0.02),
            Container(
              width: double.infinity,
              height: screenHeight * 0.16,
              decoration: BoxDecoration(
                color: const Color(0xFF2EB67D),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        height: screenWidth * 0.13,
                        width: screenWidth * 0.13,
                        margin: EdgeInsets.only(
                            left: screenWidth * 0.035,
                            top: screenHeight * 0.02),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(
                            left: screenWidth * 0.035,
                            top: screenHeight * 0.06),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Hi, Tuan Bui",
                              style: GoogleFonts.baloo2(
                                textStyle: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              "Welcome to EmpowerHR",
                              style: GoogleFonts.baloo2(
                                textStyle: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.white,
                                ),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        height: screenWidth * 0.11,
                        width: screenWidth * 0.11,
                        margin: EdgeInsets.only(
                            left: screenWidth * 0.04, top: screenHeight * 0.02),
                        decoration: BoxDecoration(
                          color: const Color(0xFF80C0A5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: IconButton(
                          onPressed: () {
                            final randomIndex =
                                Random().nextInt(qrBackgrounds.length);
                            showGeneralDialog(
                              context: context,
                              barrierDismissible: true,
                              barrierLabel: MaterialLocalizations.of(context)
                                  .modalBarrierDismissLabel,
                              barrierColor: Colors.black54,
                              pageBuilder: (context, _, __) {
                                return Container(
                                  width: screenWidth,
                                  height: screenHeight,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: AssetImage(
                                          qrBackgrounds[randomIndex]),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  child: SafeArea(
                                    child: Stack(
                                      children: [
                                        Positioned(
                                          top: 20,
                                          left: 20,
                                          child: GestureDetector(
                                            onTap: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: Container(
                                              height: 35,
                                              width: 80,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.25),
                                                    offset: const Offset(4, 4),
                                                    blurRadius: 4,
                                                  ),
                                                ],
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    const Icon(
                                                      Icons.chevron_left,
                                                      color: Colors.black,
                                                      size: 24,
                                                    ),
                                                    const SizedBox(width: 2),
                                                    Text(
                                                      'Back',
                                                      style:
                                                          GoogleFonts.poppins(
                                                        textStyle:
                                                            const TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.black,
                                                          decoration:
                                                              TextDecoration
                                                                  .none,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              // Sử dụng FutureBuilder để gọi API và hiển thị QR code
                                              FutureBuilder<QRCodeResponse>(
                                                future: getQRCode(),
                                                builder: (context, snapshot) {
                                                  if (snapshot
                                                      .connectionState ==
                                                      ConnectionState
                                                          .waiting) {
                                                    return const CircularProgressIndicator();
                                                  } else if (snapshot
                                                          .hasError ||
                                                      !snapshot.hasData ||
                                                      !snapshot.data!.success) {
                                                    return Container(
                                                      padding:
                                                          EdgeInsets.all(
                                                              screenWidth *
                                                                  0.05),
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors
                                                                .black
                                                                .withOpacity(
                                                                    0.25),
                                                            offset: const Offset(
                                                                4, 4),
                                                            blurRadius: 4,
                                                          ),
                                                        ],
                                                      ),
                                                      child: Text(
                                                        snapshot.hasError
                                                            ? 'Error: ${snapshot.error}'
                                                            : snapshot
                                                                    .data
                                                                    ?.message ??
                                                                'Failed to load QR Code',
                                                        style: GoogleFonts
                                                            .poppins(
                                                          textStyle:
                                                              const TextStyle(
                                                            fontSize: 16,
                                                            color: Colors.red,
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  } else {
                                                    // Lấy chuỗi base64 từ qrCode
                                                    final qrCodeData = snapshot
                                                        .data!.qrCode!;
                                                    // Hình ảnh QR code từ base64
                                                    return Container(
                                                      padding: EdgeInsets.all(
                                                          screenWidth * 0.05),
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors
                                                                .black
                                                                .withOpacity(
                                                                    0.25),
                                                            offset: const Offset(
                                                                4, 4),
                                                            blurRadius: 4,
                                                          ),
                                                        ],
                                                      ),
                                                      child: Image.memory(
                                                        base64Decode(qrCodeData
                                                            .split(',')
                                                            .last), // Bỏ phần "data:image/png;base64,"
                                                        height:
                                                            screenWidth * 0.5,
                                                        width:
                                                            screenWidth * 0.5,
                                                      ),
                                                    );
                                                  }
                                                },
                                              ),
                                              SizedBox(
                                                  height: screenHeight * 0.02),
                                              GestureDetector(
                                                onTap: () {
                                                  String formattedDate = DateFormat(
                                                          'EEEE, MMMM d - yyyy')
                                                      .format(now);
                                                  String formattedTime =
                                                      DateFormat('h:mm a')
                                                          .format(now);
                                                  showDialog(
                                                    context: context,
                                                    barrierDismissible: true,
                                                    barrierColor:
                                                        Colors.black54,
                                                    builder: (context) =>
                                                        Dialog(
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                      ),
                                                      child: Container(
                                                        padding: EdgeInsets.all(
                                                            screenWidth * 0.05),
                                                        child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            Image.asset(
                                                              'assets/checkSuccess.png',
                                                            ),
                                                            SizedBox(
                                                                height:
                                                                    screenHeight *
                                                                        0.02),
                                                            Text(
                                                              "You have successfully check-in at",
                                                              style: GoogleFonts
                                                                  .poppins(
                                                                textStyle:
                                                                    const TextStyle(
                                                                  fontSize: 16,
                                                                  color: Colors
                                                                      .black,
                                                                ),
                                                              ),
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                            ),
                                                            SizedBox(
                                                                height:
                                                                    screenHeight *
                                                                        0.01),
                                                            Text(
                                                              formattedDate,
                                                              style: GoogleFonts
                                                                  .poppins(
                                                                textStyle:
                                                                    const TextStyle(
                                                                  fontSize: 14,
                                                                  color: Color(
                                                                      0xFF2EB67D),
                                                                ),
                                                              ),
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                            ),
                                                            Text(
                                                              formattedTime,
                                                              style: GoogleFonts
                                                                  .poppins(
                                                                textStyle:
                                                                    const TextStyle(
                                                                  fontSize: 36,
                                                                  color: Color(
                                                                      0xFF2EB67D),
                                                                ),
                                                              ),
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                            ),
                                                            SizedBox(
                                                                height:
                                                                    screenHeight *
                                                                        0.01),
                                                            Text(
                                                              "You are on time",
                                                              style: GoogleFonts
                                                                  .poppins(
                                                                textStyle:
                                                                    const TextStyle(
                                                                  fontSize: 14,
                                                                  color: Color(
                                                                      0xFF2EB67D),
                                                                ),
                                                              ),
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                            ),
                                                            SizedBox(
                                                                height:
                                                                    screenHeight *
                                                                        0.03),
                                                            OutlinedButton(
                                                              onPressed: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                              },
                                                              style:
                                                                  OutlinedButton
                                                                      .styleFrom(
                                                                side: const BorderSide(
                                                                    color: Colors
                                                                        .black54),
                                                                shape:
                                                                    RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              20),
                                                                ),
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        20,
                                                                    vertical:
                                                                        10),
                                                              ),
                                                              child: Text(
                                                                "Close and return to home",
                                                                style:
                                                                    GoogleFonts
                                                                        .baloo2(
                                                                  textStyle:
                                                                      const TextStyle(
                                                                    fontSize:
                                                                        14,
                                                                    color: Colors
                                                                        .black,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal:
                                                          screenWidth * 0.06,
                                                      vertical: 8),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black
                                                            .withOpacity(0.25),
                                                        offset:
                                                            const Offset(4, 4),
                                                        blurRadius: 4,
                                                      ),
                                                    ],
                                                  ),
                                                  child: Text(
                                                    "Scan to check-in / check-out",
                                                    style: GoogleFonts.baloo2(
                                                      textStyle:
                                                          const TextStyle(
                                                        fontSize: 16,
                                                        color: Colors.black,
                                                        decoration:
                                                            TextDecoration.none,
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
                              },
                            );
                          },
                          icon: Image.asset('assets/qr-code.png'),
                        ),
                      ),
                      Container(
                        height: screenWidth * 0.11,
                        width: screenWidth * 0.11,
                        margin: EdgeInsets.only(
                            left: screenWidth * 0.02,
                            top: screenHeight * 0.02,
                            right: screenWidth * 0.035),
                        decoration: BoxDecoration(
                          color: const Color(0xFF80C0A5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Image.asset('assets/thongbao.png'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: screenHeight * 0.01),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.025),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      todayDate,
                      style: GoogleFonts.baloo2(
                        textStyle: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    height: screenWidth * 0.10,
                    width: screenWidth * 0.10,
                    decoration: BoxDecoration(
                      color: const Color(0xFF80C0A5).withOpacity(0.4),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.calendar_month,
                        color: Color(0xFF80C0A5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: screenHeight * 0.01),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.025),
              child: Row(
                children: daysOfWeek.map((day) {
                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: day['isToday']
                            ? const Color(0xFF2EB67D)
                            : Color(0xFFBEC3C1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            day['name'],
                            style: GoogleFonts.baloo2(
                              textStyle: TextStyle(
                                fontSize: 14,
                                color: day['isToday']
                                    ? Colors.white
                                    : Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            day['date'].toString(),
                            style: GoogleFonts.baloo2(
                              textStyle: TextStyle(
                                fontSize: 16,
                                color: day['isToday']
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            height: 6,
                            width: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: day['isToday']
                                  ? Color(0xFFD6FFCE)
                                  : Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              margin: EdgeInsets.all(10),
              height: 185,
              width: 411,
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      offset: const Offset(0, 0),
                      blurRadius: 4,
                    ),
                  ],
                  borderRadius: BorderRadius.circular(10)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Time Check-in",
                        style: GoogleFonts.baloo2(
                          textStyle: const TextStyle(
                            fontSize: 20,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Text(
                        "40:00:05",
                        style: GoogleFonts.baloo2(
                          textStyle: const TextStyle(
                              fontSize: 50,
                              color: Colors.black,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    height: 70,
                    width: 70,
                    decoration: BoxDecoration(
                      color: Color(0xFF069855).withOpacity(0.19),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Image.asset('assets/CombinedShape.png'),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}