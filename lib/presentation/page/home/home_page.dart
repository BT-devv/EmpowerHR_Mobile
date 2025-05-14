import 'dart:convert';
import 'package:empowerhr_moblie/data/models/user_model.dart';
import 'package:empowerhr_moblie/data/service/api_service.dart';
import 'package:empowerhr_moblie/data/service/socket_service.dart';
import 'package:empowerhr_moblie/domain/usecases/QRCodeResponse_usecase.dart';
import 'package:empowerhr_moblie/domain/usecases/get_file_byid.dart';
import 'package:empowerhr_moblie/domain/usecases/get_user_by_id_usecase.dart';
import 'package:empowerhr_moblie/presentation/page/home/noti_icon.dart';
import 'package:empowerhr_moblie/presentation/page/home/notification_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  void initState() {
    super.initState();
    _connectWebSocket(); // Kết nối WebSocket khi vào HomePage
  }

  Future<void> _connectWebSocket() async {
    final prefs = await SharedPreferences.getInstance();
    final employeeID = prefs.getString('employeeID');
    if (employeeID != null) {
      await NotificationService().init(employeeID);
    } else {
      print('EmployeeID not found in SharedPreferences');
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color(0xFF2EB67D),
      statusBarIconBrightness: Brightness.light,
    ));

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            buildHeader(context),
            SizedBox(height: 10),
            buildDateSection(context),
            SizedBox(height: 10),
            buildWeekDays(context),
            buildCheckInSection(context),
            buildEventSection(context),
          ],
        ),
      ),
    );
  }

  Widget buildHeader(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    DateTime now = DateTime.now();

    Future<Uint8List> getAvatarFuture() async {
      try {
        final prefs = await SharedPreferences.getInstance();
        final photoID = prefs.getString('photoID') ?? '';

        if (photoID.isEmpty) {
          return Uint8List(0);
        }

        final avatarData = await getFileById(photoID);
        return avatarData;
      } catch (e) {
        print('Error fetching avatar in buildHeader: $e');
        return Uint8List(0);
      }
    }

    return FutureBuilder<UserModel>(
      future: getUserById(),
      builder: (context, snapshot) {
        String userName =
            snapshot.hasData ? snapshot.data!.lastName ?? 'User' : 'Loading...';
        if (snapshot.hasError) userName = 'Error loading name';

        return Container(
          width: double.infinity,
          height: screenHeight * 0.17,
          decoration: const BoxDecoration(
            color: Color(0xFF2EB67D),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(10),
              bottomRight: Radius.circular(10),
            ),
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
                        left: screenWidth * 0.035, top: screenHeight * 0.02),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(color: Colors.grey, width: 1),
                    ),
                    child: FutureBuilder<Uint8List>(
                      future: getAvatarFuture(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError ||
                            !snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          print(
                              'Avatar loading failed, data empty, or error: ${snapshot.error}');
                          return  Image.asset('assets/default_avatar.png');
                        }
                        try {
                          print(
                              'Displaying image with length: ${snapshot.data!.length} bytes');
                          return ClipOval(
                            child: Image.memory(
                              snapshot.data!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                print('Image.memory error: $error');
                                return const Icon(Icons.error, color: Colors.red);
                              },
                            ),
                          );
                        } catch (e) {
                          print('Exception during image display: $e');
                          return const Icon(Icons.error, color: Colors.red);
                        }
                      },
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(
                        left: screenWidth * 0.035, top: screenHeight * 0.06),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Hi, $userName",
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
                    decoration:  BoxDecoration(
                      color: Color(0xFF80C0A5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: IconButton(
                      onPressed: () {
                        final randomIndex = Random().nextInt(qrBackgrounds.length);
                        showGeneralDialog(
                          context: context,
                          barrierDismissible: true,
                          barrierLabel: MaterialLocalizations.of(context)
                              .modalBarrierDismissLabel,
                          barrierColor: Colors.black54,
                          pageBuilder: (context, _, __) {
                            return buildQRDialog(context, screenWidth,
                                screenHeight, randomIndex, now);
                          },
                        );
                      },
                      icon: Image.asset('assets/qr-code.png'),
                    ),
                  ),
                  const NotificationIcon(), // Thay thế Container cũ bằng NotificationIcon
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildDateSection(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    DateTime now = DateTime.now();
    String todayDate = DateFormat('EEEE, MMMM d ').format(now);

    return Padding(
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
              iconSize: 20,
              onPressed: () {},
              icon: const Icon(
                Icons.calendar_month,
                color: Color(0xFF80C0A5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildWeekDays(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    DateTime now = DateTime.now();
    List<Map<String, dynamic>> daysOfWeek = [];
    DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
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

    return Padding(
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
                    : Color.fromARGB(255, 159, 160, 160),
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
                        color: day['isToday'] ? Colors.white : Colors.white,
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
                        color: day['isToday'] ? Colors.white : Colors.white,
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
                          : Color.fromARGB(255, 215, 221, 219),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget buildCheckInSection(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
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
        borderRadius: BorderRadius.circular(10),
      ),
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
                    fontWeight: FontWeight.bold,
                  ),
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
          ),
        ],
      ),
    );
  }

  Widget buildEventSection(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    DateTime now = DateTime.now();

    return Container(
      margin: EdgeInsets.all(10),
      height: 340,
      width: 411,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Color(0xFF068998),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 15,
            left: 15,
            child: SizedBox(
              width: screenWidth * 0.6,
              child: Text(
                "Webinar: X's Grok AI is scanning your tweets. Here's how to disable it",
                style: GoogleFonts.baloo2(
                  textStyle: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 15,
            right: 15,
            child: Container(
              height: 70,
              width: 100,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Tuesday",
                    style: GoogleFonts.baloo2(
                      textStyle: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    "25-2-2025",
                    style: GoogleFonts.baloo2(
                      textStyle: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Text(
                    "15:30 (GMT+7)",
                    style: GoogleFonts.baloo2(
                      textStyle: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 15,
            left: 15,
            child: Row(
              children: [
                const Icon(
                  Icons.location_on,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 5),
                Text(
                  "Google Meet",
                  style: GoogleFonts.baloo2(
                    textStyle: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 15,
            right: 15,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white),
                backgroundColor: const Color(0xFFFFFFFF).withOpacity(0.77),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              ),
              child: Row(
                children: [
                  Text(
                    "Register now",
                    style: GoogleFonts.baloo2(
                      textStyle: const TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  const Icon(
                    Icons.arrow_forward,
                    color: Colors.black,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildQRDialog(BuildContext context, double screenWidth,
      double screenHeight, int randomIndex, DateTime now) {
    return Container(
      width: screenWidth,
      height: screenHeight,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(qrBackgrounds[randomIndex]),
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
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        offset: const Offset(4, 4),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.chevron_left,
                          color: Colors.black,
                          size: 24,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          'Back',
                          style: GoogleFonts.poppins(
                            textStyle: const TextStyle(
                              fontSize: 12,
                              color: Colors.black,
                              decoration: TextDecoration.none,
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FutureBuilder<QRCodeResponse>(
                    future: getQRCode(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError ||
                          !snapshot.hasData ||
                          !snapshot.data!.success) {
                        return Container(
                          padding: EdgeInsets.all(screenWidth * 0.05),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.25),
                                offset: const Offset(4, 4),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Text(
                            snapshot.hasError
                                ? 'Error: ${snapshot.error}'
                                : snapshot.data?.message ??
                                    'Failed to load QR Code',
                            style: GoogleFonts.poppins(
                              textStyle: const TextStyle(
                                fontSize: 16,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        );
                      } else {
                        final qrCodeData = snapshot.data!.qrCode!;
                        return Container(
                          padding: EdgeInsets.all(screenWidth * 0.05),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.25),
                                offset: const Offset(4, 4),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Image.memory(
                            base64Decode(qrCodeData.split(',').last),
                            height: screenWidth * 0.5,
                            width: screenWidth * 0.5,
                          ),
                        );
                      }
                    },
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  GestureDetector(
                    onTap: () {
                      String formattedDate =
                          DateFormat('EEEE, MMMM d - yyyy').format(now);
                      String formattedTime = DateFormat('h:mm a').format(now);
                      showDialog(
                        context: context,
                        barrierDismissible: true,
                        barrierColor: Colors.black54,
                        builder: (context) => Dialog(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Container(
                            padding: EdgeInsets.all(screenWidth * 0.05),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset('assets/checkSuccess.png'),
                                SizedBox(height: screenHeight * 0.02),
                                Text(
                                  "You have successfully check-in at",
                                  style: GoogleFonts.poppins(
                                    textStyle: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: screenHeight * 0.01),
                                Text(
                                  formattedDate,
                                  style: GoogleFonts.poppins(
                                    textStyle: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF2EB67D),
                                    ),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                Text(
                                  formattedTime,
                                  style: GoogleFonts.poppins(
                                    textStyle: const TextStyle(
                                      fontSize: 36,
                                      color: Color(0xFF2EB67D),
                                    ),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: screenHeight * 0.01),
                                Text(
                                  "You are on time",
                                  style: GoogleFonts.poppins(
                                    textStyle: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF2EB67D),
                                    ),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: screenHeight * 0.03),
                                OutlinedButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    Navigator.of(context).pop();
                                  },
                                  style: OutlinedButton.styleFrom(
                                    side:
                                        const BorderSide(color: Colors.black54),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 10),
                                  ),
                                  child: Text(
                                    "Close and return to home",
                                    style: GoogleFonts.baloo2(
                                      textStyle: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black,
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
                          horizontal: screenWidth * 0.06, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            offset: const Offset(4, 4),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Text(
                        "Scan to check-in / check-out",
                        style: GoogleFonts.baloo2(
                          textStyle: const TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                            decoration: TextDecoration.none,
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
  }
}